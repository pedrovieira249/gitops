package main

import "net/http"

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("<h1>Olá desenvolvedor, seja bem-vindo!</h1>"))
	})
	http.ListenAndServe(":8080", nil)
}
