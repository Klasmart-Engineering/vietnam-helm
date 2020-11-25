package main

import (
	"os"

	"github.com/fsnotify/fsnotify"
	"go.uber.org/zap"
	v1 "k8s.io/api/batch/v1"
	"k8s.io/apimachinery/pkg/util/yaml"
)

func processConfigFile(logger *zap.Logger, jobConfig string) (*v1.Job, error) {
	logger.Info("opening job yaml", zap.String("jobConfig", jobConfig))
	f, err := os.Open(jobConfig)
	if err != nil {
		logger.Error("error opening file", zap.Error(err))
		return nil, err
	}

	d := yaml.NewYAMLOrJSONDecoder(f, 128)
	var job v1.Job
	err = d.Decode(&job)
	if err != nil {
		logger.Error("error decoding file", zap.Error(err))
		return nil, err
	}
	logger.Info("decoded YAML file")

	return &job, nil
}

func filewatcher(logger *zap.Logger, file string, jobConfigChan chan<- *v1.Job) {
	logger.Info("started filewatcher", zap.String("file", file))

	// Inital read
	job, err := processConfigFile(logger, file)
	if err != nil {
		logger.Fatal("unable to perform initial read of file",
			zap.String("file", file),
			zap.Error(err))
	}
	jobConfigChan <- job

	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		logger.Fatal("unable to get new watcher", zap.Error(err))
	}
	defer watcher.Close()

	done := make(chan bool)
	go func() {
		for {
			select {
			case event, ok := <-watcher.Events:
				if !ok {
					return
				}
				logger.Info("new event", zap.String("name", event.Name), zap.String("op", event.Op.String()))
				if event.Op&fsnotify.Write == fsnotify.Write {
					logger.Info("modified file", zap.String("name", event.Name))
					job, err := processConfigFile(logger, event.Name)
					if err != nil {
						logger.Error("error processing updated config", zap.Error(err))
						continue
					}
					jobConfigChan <- job
				}
			case err, ok := <-watcher.Errors:
				if !ok {
					return
				}
				logger.Fatal("watcher error", zap.Error(err))
			}
		}
	}()

	err = watcher.Add(file)
	if err != nil {
		logger.Fatal("unable to add file to watcher", zap.String("file", file), zap.Error(err))
	}
	<-done
}
