package main

import (
	"context"
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"strings"
	"time"

	"git.sr.ht/~yoink00/goflenfig"
	"go.uber.org/zap"

	v1 "k8s.io/api/batch/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/util/rand"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
)

// Namespace returns the namespace this pod is in
func Namespace() string {
	// This way assumes you've set the POD_NAMESPACE environment variable using the downward API.
	// This check has to be done first for backwards compatibility with the way InClusterConfig was originally set up
	if ns, ok := os.LookupEnv("POD_NAMESPACE"); ok {
		return ns
	}

	// Fall back to the namespace associated with the service account token, if available
	if data, err := ioutil.ReadFile("/var/run/secrets/kubernetes.io/serviceaccount/namespace"); err == nil {
		if ns := strings.TrimSpace(string(data)); len(ns) > 0 {
			return ns
		}
	}

	return "default"
}

// PodName return the name of this pod
func PodName() (string, error) {
	if name, ok := os.LookupEnv("POD_NAME"); ok {
		return name, nil
	}

	if data, err := ioutil.ReadFile("/etc/podname"); err == nil {
		if name := strings.TrimSpace(string(data)); len(name) > 0 {
			return name, nil
		}
	}

	return "", errors.New("unable to get pod name")
}

var desiredPodsGetters map[string]desiredPods

func main() {
	logger, _ := zap.NewProduction()
	defer logger.Sync()
	logger.Info("starting SFU manager")

	var jobConfig string
	var desiredPodsGetterChoice string
	var initialDesiredPods int
	goflenfig.EnvPrefix("SFU_MANAGER_")
	goflenfig.StringVar(&jobConfig, "job", "/etc/sfu-manager/job.yaml", "The template for creating a job")
	goflenfig.StringVar(&desiredPodsGetterChoice, "desired-pods-getter", "http", "The desired pod getter to use")
	goflenfig.IntVar(&initialDesiredPods, "pods", 1, "The inital number of desired pods")
	// Initalise desired pod getters
	for _, d := range desiredPodsGetters {
		d.Init()
	}

	goflenfig.Parse()

	jobConfigChan := make(chan *v1.Job, 1)
	desiredPodsChan := make(chan int, 1)
	desiredPodsGetter := desiredPodsGetters[desiredPodsGetterChoice]
	if desiredPodsGetter == nil {
		logger.Fatal("can't find desired pod getter", zap.String("desiredPodsGetterChoice", desiredPodsGetterChoice))
	}
	go filewatcher(logger, jobConfig, jobConfigChan)
	go manageJobs(logger, jobConfigChan, desiredPodsChan)

	desiredPodsChan <- initialDesiredPods
	logger.Fatal("error getting desired pods", zap.Error(desiredPodsGetter.Run(logger, desiredPodsChan)))
}

func manageJobs(logger *zap.Logger, jobConfigChan <-chan *v1.Job, desiredPodsChan <-chan int) {
	// creates the in-cluster config
	config, err := rest.InClusterConfig()
	if err != nil {
		logger.Fatal("error getting in-cluster config", zap.Error(err))
	}
	// creates the clientset
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		logger.Fatal("error creating client set", zap.Error(err))
	}

	namespace := Namespace()
	podName, err := PodName()
	if err != nil {
		logger.Fatal("pod name error", zap.Error(err))
	}

	self, err := clientset.CoreV1().Pods(namespace).Get(context.TODO(), podName, metav1.GetOptions{})
	if err != nil {
		logger.Fatal("unable to get self from api", zap.Error(err))
	}

	var job *v1.Job
	var desiredJobs int

	ticker := time.NewTicker(10 * time.Second)
	for {
		select {
		case <-ticker.C:
			if job == nil {
				logger.Info("no job configuration")
				continue
			}

			if desiredJobs == 0 {
				logger.Info("no desired jobs", zap.Int("desiredJobs", desiredJobs))
				continue
			}

			jobs, err := clientset.BatchV1().Jobs(namespace).List(context.TODO(), metav1.ListOptions{
				LabelSelector: "app.kubernetes.io/instance=vietnam-sfu",
			})
			if err != nil {
				panic(err)
			}
			var filteredJobs []*v1.Job
			for _, job := range jobs.Items {
				if job.Status.Active > 0 {
					filteredJobs = append(filteredJobs, &job)
				}
			}

			logger.Info("SFU jobs in the cluster",
				zap.Int("filteredJobs", len(filteredJobs)),
				zap.Int("jobs", len(jobs.Items)))

			if len(filteredJobs) < int(desiredJobs) {
				logger.Info("creating new jobs",
					zap.Int("desiredJobs", desiredJobs),
					zap.Int("newJobs", 1),
					zap.Int("sfuCount", len(filteredJobs)))

				job.Name = fmt.Sprintf("sfu-%s", rand.String(6))
				job.Namespace = namespace

				isController := true
				job.OwnerReferences = []metav1.OwnerReference{
					{
						APIVersion: "v1",
						Kind:       "Pod",
						Name:       podName,
						Controller: &isController,
						UID:        self.GetUID(),
					},
				}

				newJob, err := clientset.BatchV1().Jobs(namespace).Create(context.TODO(), job, metav1.CreateOptions{})
				if err != nil {
					logger.Fatal("unable to create new job", zap.Error(err))
				}
				logger.Info("new job created", zap.String("jobName", newJob.Name))
			}

			logger.Info("sleeping")
		case j := <-jobConfigChan:
			logger.Info("updating job configuration")
			job = j
		case d := <-desiredPodsChan:
			logger.Info("desired jobs updated", zap.Int("desiredJobs", d))
			desiredJobs = d
		}
	}
}
