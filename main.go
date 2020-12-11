package main

import (
	"net/http"

	"github.com/go-chi/chi"
	"github.com/go-chi/chi/middleware"
	"github.com/go-chi/render"
	log "github.com/sirupsen/logrus"
	"github.com/srleyva/date-api/pkg/logs"
	"github.com/srleyva/date-api/routes/date"
)

// VERSION as passed in by build args
var VERSION = "local-dev"

func main() {
	router := chi.NewRouter()

	logger := log.New()
	logger.Formatter = &log.JSONFormatter{
		// disable, as we set our own
		DisableTimestamp: true,
	}

	logger.Level = log.DebugLevel
	logger.Formatter = &log.JSONFormatter{DisableTimestamp: true}
	router.Use(
		render.SetContentType(render.ContentTypeJSON),
		logs.NewStructuredLogger(logger),
		middleware.Recoverer,
		middleware.SetHeader("application-version", VERSION),
	)

	router.Mount("/", date.Routes(logger).Router)

	logger.Infof("Running Date API Version %s at :3000", VERSION)
	http.ListenAndServe(":3000", router)
}
