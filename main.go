package main

import (
	"bytes"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"github.com/takeoff-projects/oluchkov_l1/tododb"
)

var projectID string 

func main() {
	projectID = os.Getenv("GOOGLE_CLOUD_PROJECT")
	if projectID == "" {
		log.Fatal(`You need to set the environment variable "GOOGLE_CLOUD_PROJECT"`)
	}
	log.Printf("GOOGLE_CLOUD_PROJECT is set to %s", projectID)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("Port set to: %s", port)

	fs := http.FileServer(http.Dir("assets"))
	mux := http.NewServeMux()

	// This serves the static files in the assets folder
	mux.Handle("/assets/", http.StripPrefix("/assets/", fs))

	// The rest of the routes
	mux.HandleFunc("/", indexHandler)
	mux.HandleFunc("/about", aboutHandler)

	log.Printf("Webserver listening on Port: %s", port)
	http.ListenAndServe(":"+port, mux)
}
	
func indexHandler(w http.ResponseWriter, r *http.Request) {
	var todos []tododb.Todo
	todos, error := tododb.GetTodos()
	if error != nil {
		fmt.Print(error)
	}

	data := HomePageData{
		PageTitle: "Todos ans Tasks Page",
		Todos: todos,
	}

	var tpl = template.Must(template.ParseFiles("static/index.html", "static/layout.html"))

	buf := &bytes.Buffer{}
	err := tpl.Execute(buf, data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		log.Println(err.Error())
		return
	}

	buf.WriteTo(w)
	log.Println("Home Page Served")
}

func aboutHandler(w http.ResponseWriter, r *http.Request) {
	data := AboutPageData{
		PageTitle: "About GoTodos",
	}

	var tpl = template.Must(template.ParseFiles("static/about.html", "static/layout.html"))

	buf := &bytes.Buffer{}
	err := tpl.Execute(buf, data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		log.Println(err.Error())
		return
	}

	buf.WriteTo(w)
	log.Println("About Page Served")
}

// HomePageData for Index template
type HomePageData struct {
	PageTitle string
	Todos []tododb.Todo
}

// AboutPageData for About template
type AboutPageData struct {
	PageTitle string
}

