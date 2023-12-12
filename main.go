package main

import (
	"errors"
	"fmt"
	"github.com/lplazas2/reverser/internal"
	"io"
	"log/slog"
	"net/http"
	"os"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		slog.Info("environment variable PORT was not set, defaulting to 9090")
		port = "9090"
	}

	debug := os.Getenv("DEBUG")
	if debug != "" {
		h := slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelDebug})
		slog.SetDefault(slog.New(h))
	}

	svc := internals.NewReverseService(&internals.NoOPDB{})
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {

		reversed, err := svc.ReverseIP(r)

		if err != nil {
			slog.Error("Failed reverse service", err)
			if errors.Is(err, &internals.NotImplementedError{}) {
				http.Error(w, err.Error(), http.StatusNotImplemented)
			} else {
				http.Error(w, err.Error(), http.StatusInternalServerError)
			}
		}
		_, err = io.WriteString(w, reversed)
		if err != nil {
			slog.Error("Failed sending response", err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
	})

	addr := fmt.Sprintf("0.0.0.0:%s", port)
	slog.Info("Listening to requests on", "addr", addr)

	if err := http.ListenAndServe(addr, nil); err != nil {
		panic(err)
	}
}
