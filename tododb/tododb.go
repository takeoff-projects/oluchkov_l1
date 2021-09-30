package tododb

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"
	"cloud.google.com/go/datastore"
)

var projectID string

// ToDos stored in Datastore
type Todo struct {
	Caption    string    `datastore:"caption"`
	Added      time.Time `datastore:"added"`
	Term       time.Time `datastore:"term"`
	ListGroup  string    `datastore:"listgroup"`
	Image      string    `datastore:"image"`
	Urgency    int       `datastore:"urgency"`
	//Importance int       `datastore:"urgency"`
	Name       string     // The ID used in the datastore.
}

// Get all todo records from datastore ordered by urgency
func GetTodos() ([]Todo, error) {

	projectID = os.Getenv("GOOGLE_CLOUD_PROJECT")
	if projectID == "" {
		log.Fatal(`You need to set the environment variable "GOOGLE_CLOUD_PROJECT"`)
	}

	var todos []Todo
	ctx := context.Background()
	client, err := datastore.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Could not create datastore client: %v", err)
	}

	// Create a query to fetch all todo entities".
	query := datastore.NewQuery("Todo").Order("-urgency")
	keys, err := client.GetAll(ctx, query, &todos)
	if err != nil {
		fmt.Println(err)
		return nil, err
	}

	// Set the id field on each Task from the corresponding key.
	for i, key := range keys {
		todos[i].Name = key.Name
	}

	client.Close()
	return todos, nil
}
