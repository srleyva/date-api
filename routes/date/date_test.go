package date_test

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"reflect"
	"testing"

	"github.com/go-chi/chi"
	log "github.com/sirupsen/logrus"

	. "github.com/srleyva/date-api/routes/date"
)

func TestRoute(t *testing.T) {
	_, w, _ := os.Pipe()
	logger := log.New()
	logger.Out = w

	// Create the handler
	handler := Routes(logger)

	routes := map[string][]string{}
	walkFunc := func(method string, route string, handler http.Handler, middlewares ...func(http.Handler) http.Handler) error {
		routes[method] = append(routes[method], route)
		return nil
	}

	if err := chi.Walk(handler.Router, walkFunc); err != nil {
		t.Fatalf("Err printing routes: %s", err)
	}

	// Check GET Routes
	expected_get_routes := []string{"/"}
	if !reflect.DeepEqual(expected_get_routes, routes["GET"]) {
		t.Errorf("Wrong routes: Expected: %v Actual %v", expected_get_routes, routes["GET"])
	}

}

func TestGetDateTime(t *testing.T) {
	_, w, _ := os.Pipe()
	logger := log.New()
	logger.Out = w

	// Create the handler
	handler := Routes(logger)

	recorder := httptest.NewRecorder()
	request := httptest.NewRequest("GET", "/", nil)

	handler.GetDatetime(recorder, request)

	if recorder.Code != 200 {
		t.Errorf("%d return where 200 expected", recorder.Code)
	}

	result := map[string]interface{}{}

	decoder := json.NewDecoder(recorder.Body)
	if err := decoder.Decode(&result); err != nil {
		t.Errorf("error decoding response: %s", err)
	}

	if result["time"] == nil {
		t.Errorf("wrong result returned: %v", result)
	}

}
