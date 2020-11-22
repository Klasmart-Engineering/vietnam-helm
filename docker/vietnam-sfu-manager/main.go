package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"
	"strings"
	"sync/atomic"
	"time"

	"git.sr.ht/~yoink00/goflenfig"
	"git.sr.ht/~yoink00/zaplog"
	"github.com/go-chi/chi"
	"github.com/go-chi/chi/middleware"
	"go.uber.org/zap"

	v1 "k8s.io/api/batch/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/util/rand"
	"k8s.io/apimachinery/pkg/util/yaml"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
)

var desiredJobs int32 = 6

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

func main() {
	logger, _ := zap.NewProduction()
	defer logger.Sync()
	logger.Info("starting SFU manager")

	var jobConfig string
	goflenfig.EnvPrefix("SFU_MANAGER_")
	goflenfig.StringVar(&jobConfig, "job", "job.yaml", "The template for creating a job")
	goflenfig.Parse()

	logger.Info("opening job yaml", zap.String("jobConfig", jobConfig))
	f, err := os.Open(jobConfig)
	if err != nil {
		panic(err)
	}

	d := yaml.NewYAMLOrJSONDecoder(f, 128)
	var job v1.Job
	err = d.Decode(&job)
	if err != nil {
		panic(err)
	}
	logger.Info("decoded YAML file")

	r := chi.NewRouter()
	// A good base middleware stack
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(zaplog.ZapLog(logger))
	r.Use(middleware.Recoverer)

	r.Post("/", func(w http.ResponseWriter, r *http.Request) {
		defer r.Body.Close()

		body, err := ioutil.ReadAll(r.Body)
		if err != nil {
			logger.Error("unable to read body", zap.Error(err))
			w.WriteHeader(400)
			return
		}

		newDesiredJobs, err := strconv.Atoi(string(body))
		if err != nil {
			logger.Error("unable to convert body", zap.Error(err))
			w.WriteHeader(400)
			return
		}

		atomic.StoreInt32(&desiredJobs, int32(newDesiredJobs))

		w.WriteHeader(http.StatusCreated)
	})

	go func() {
		logger.Fatal("server exit", zap.Error(http.ListenAndServe(":8080", r)))
	}()

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

	originalJobs := -1
	startedJobs := 0

	for {
		jobs, err := clientset.BatchV1().Jobs(namespace).List(context.TODO(), metav1.ListOptions{
			LabelSelector: "app.kubernetes.io/instance=vietnam-sfu",
		})
		if err != nil {
			panic(err)
		}
		logger.Info("SFU jobs in the cluster", zap.Int("sfuCount", len(jobs.Items)))
		if originalJobs < 0 {
			originalJobs = len(jobs.Items)
		} else {
			// This is to prevent us starting more jobs because we're unable to detect
			// running jobs. This will some thought.
			if (len(jobs.Items) - originalJobs) < startedJobs {
				logger.Error("no jobs started", zap.Int("sfuCount", len(jobs.Items)))
				time.Sleep(10 * time.Second)
				continue
			}
		}

		if len(jobs.Items) < int(desiredJobs) {
			logger.Info("creating new jobs",
				zap.Int32("desiredJobs", desiredJobs),
				zap.Int("newJobs", 1),
				zap.Int("sfuCount", len(jobs.Items)))

			job.Name = fmt.Sprintf("vietnam-sfu-%s", rand.String(6))
			job.Namespace = namespace

			newJob, err := clientset.BatchV1().Jobs(namespace).Create(context.TODO(), &job, metav1.CreateOptions{})
			if err != nil {
				logger.Fatal("unable to create new job", zap.Error(err))
			}
			logger.Info("new job created", zap.String("jobName", newJob.Name))
		}

		logger.Info("sleeping for 10 seconds")
		time.Sleep(10 * time.Second)
	}
}
