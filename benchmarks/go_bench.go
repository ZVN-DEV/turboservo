// Go benchmark — equivalent API to TurboServo benchmark
// Run: go run benchmarks/go_bench.go
package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type User struct {
	ID    int    `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
}

var users = map[string]User{
	"1": {ID: 1, Name: "Alice", Email: "alice@example.com"},
	"2": {ID: 2, Name: "Bob", Email: "bob@example.com"},
}

func main() {
	// Endpoint 1: Simple JSON response
	http.HandleFunc("/json", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Write([]byte(`{"message":"Hello, World!"}`))
	})

	// Endpoint 2: Echo posted JSON
	http.HandleFunc("/echo", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		body, _ := io.ReadAll(r.Body)
		w.Write(body)
	})

	// Endpoint 3: In-memory lookup
	http.HandleFunc("/user", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		id := r.URL.Query().Get("id")
		user, ok := users[id]
		if !ok {
			w.WriteHeader(404)
			w.Write([]byte(`{"error":"Not Found"}`))
			return
		}
		json.NewEncoder(w).Encode(user)
	})

	// Endpoint 4: Headers inspection
	http.HandleFunc("/headers", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		resp := map[string]string{
			"user_agent": r.Header.Get("User-Agent"),
			"accept":     r.Header.Get("Accept"),
		}
		json.NewEncoder(w).Encode(resp)
	})

	fmt.Println("Go benchmark server running on http://localhost:3002")
	http.ListenAndServe(":3002", nil)
}
