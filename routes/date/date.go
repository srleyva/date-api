// Package date returns the date
package date

import (
	"net/http"
	"time"

	log "github.com/sirupsen/logrus"

	"github.com/go-chi/chi"
	"github.com/go-chi/render"
)

// Handler contains the logrus.Logger and router making loggin possible from inside API functions
type Handler struct {
	Router *chi.Mux
	Logger *log.Logger
}

// Routes creates routes for the date module
func Routes(logger *log.Logger) *Handler {
	router := chi.NewRouter()

	handler := &Handler{router, logger}

	// Routes for the location namespace
	router.Get("/", handler.GetDatetime)

	return handler
}

// GetDatetime retrieves current date and time and returns in JSON
func (h *Handler) GetDatetime(w http.ResponseWriter, r *http.Request) {
	render.JSON(w, r, map[string]interface{}{"time": time.Now()})
}
