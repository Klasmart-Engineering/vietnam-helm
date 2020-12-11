package main

import (
	"context"
	"errors"
	"io/ioutil"
	"net/http"
	"strconv"
	"time"

	"git.sr.ht/~yoink00/goflenfig"
	"git.sr.ht/~yoink00/zaplog"
	"github.com/go-chi/chi"
	"github.com/go-chi/chi/middleware"
	"github.com/prometheus/client_golang/api"
	prometheus "github.com/prometheus/client_golang/api/prometheus/v1"
	"github.com/prometheus/common/model"
	"go.uber.org/zap"
)

type desiredPods interface {
	Init()
	Run(logger *zap.Logger, dPods chan<- int) error
}

type httpDesiredPods struct {
	port int
}

func (d *httpDesiredPods) Init() {
	goflenfig.IntVar(&d.port, "http-port", 8080, "HTTP Port for HTTP Desired Pods to listen on")
}
func (d *httpDesiredPods) Run(logger *zap.Logger, dPods chan<- int) error {
	logger.Info("using http desired pod getter")

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

		logger.Info("updating desired SFUs number", zap.Int("newDesiredJobs", newDesiredJobs))
		dPods <- newDesiredJobs

		w.WriteHeader(http.StatusCreated)
	})

	return http.ListenAndServe(":8080", r)
}

type prometheusDesiredPods struct {
	host             string
	availableQuery   string
	totalQuery       string
	desiredAvailable int
}

func (d *prometheusDesiredPods) Init() {
	goflenfig.StringVar(&d.host, "prom-host", "localhost:9090", "Prometheus host to connect to")
	goflenfig.StringVar(&d.availableQuery, "prom-available-query", "up", "Query for prometheus to discover number of available SFUs")
	goflenfig.StringVar(&d.totalQuery, "prom-total-query", "up", "Query for prometheus to discover total number of SFUs")
	goflenfig.IntVar(&d.desiredAvailable, "prom-desired-available", 2, "The number of SFUs that should be available")
}

func (d *prometheusDesiredPods) queryProm(
	ctx context.Context,
	logger *zap.Logger,
	api prometheus.API,
	query string) (int, error) {

	val, warn, err := api.Query(ctx, d.availableQuery, time.Now())
	if err != nil {
		logger.Error("error querying prometheus", zap.Error(err))
		return 0, err
	}
	if warn != nil && len(warn) > 0 {
		logger.Error("prometheus query resulted in warnings", zap.Strings("warn", warn))
	}
	if val == nil {
		logger.Error("prometheus value is nil")
		return 0, errors.New("prometheus value is nil")
	}

	logger.Info("prometheus result", zap.Any("val", val))
	switch val.Type() {
	case model.ValScalar:
		scalarVal := val.(*model.Scalar)
		return int(scalarVal.Value), nil
	case model.ValVector:
		vectorVal := val.(model.Vector)
		if vectorVal.Len() == 0 {
			logger.Error("prometheus result vector has no results", zap.Any("vectorVal", vectorVal))
			return 0, errors.New("prometheus result vector has no results")
		}
		s := ([]*model.Sample)(vectorVal)[0]
		return int(s.Value), nil
	default:
		logger.Error("prometheus result is not supported", zap.Int("valType", int(val.Type())))
		return 0, errors.New("prometheus result is not supported")
	}
}

func (d *prometheusDesiredPods) Run(logger *zap.Logger, dPods chan<- int) error {
	logger.Info("using prometheus desired pod getter")

	cfg := api.Config{
		Address: d.host,
	}
	cl, err := api.NewClient(cfg)
	if err != nil {
		logger.Error("unable to create prometheus client", zap.Error(err))
		return err
	}

	api := prometheus.NewAPI(cl)
	for {
		time.Sleep(1 * time.Minute)
		logger.Info("getting data from prometheus")

		ctx, cancel := context.WithTimeout(context.Background(), 1*time.Minute)
		defer cancel()

		available, err := d.queryProm(ctx, logger, api, d.availableQuery)
		if err != nil {
			logger.Error("error querying prometheus for available SFUs", zap.Error(err))
			continue
		}
		if available >= d.desiredAvailable {
			logger.Info("available SFUs >= desired SFUs", zap.Int("available", available), zap.Int("desiredAvailable", d.desiredAvailable))
			continue
		}

		total, err := d.queryProm(ctx, logger, api, d.totalQuery)
		if err != nil {
			logger.Error("error querying prometheus for total SFUs", zap.Error(err))
			continue
		}

		newTotal := total + (d.desiredAvailable - available)
		logger.Info("updating desired SFUs number", zap.Int("newTotal", newTotal))
		dPods <- newTotal
	}
}

func init() {
	desiredPodsGetters = map[string]desiredPods{
		"http":       &httpDesiredPods{},
		"prometheus": &prometheusDesiredPods{},
	}
}
