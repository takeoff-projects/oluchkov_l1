terraform {
  required_version = ">= 0.14"
  required_providers {
    google = ">= 3.17"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

locals {
  service_name    = "todoapp"
  deployment_name = "todoapp"
# index_path_file    = "index.yaml"
# todos_worker_sa  = "serviceAccount:${google_service_account.todos_worker.email}"
}

# Create a service account
#resource "google_service_account" "todos_worker" {
#  account_id   = "todos-worker"
#  display_name = "Todos Worker SA"
#}
#resource "google_service_account_key" "pets_worker_key" {
#  service_account_id = google_service_account.todos_worker.name
#  public_key_type    = "TYPE_X509_PEM_FILE"
#}
# Set permissions
#resource "google_project_iam_binding" "service_permissions" {
#  for_each = toset([
#    "run.invoker", "datastore.owner","appengine.appAdmin"
#  ])
#  role       = "roles/${each.key}"
#  members    = [local.todos_worker_sa]
#  depends_on = [google_service_account.todos_worker]
#}

resource "google_project_service" "run" {
  provider = google
  project  = var.gcp_project_id  
  service = "run.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "iam" {
  provider = google
  project  = var.gcp_project_id  
  service = "iam.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "cloudbuild" {
  provider = google
  project  = var.gcp_project_id  
  service = "cloudbuild.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "datastore" {
  provider = google
  project  = var.gcp_project_id       
  service = "datastore.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "enable_apigateway_service" {
  provider = google
  project  = var.gcp_project_id
  service  = "apigateway.googleapis.com"
  disable_on_destroy = true
}

module "datastore" {
  source  = "terraform-google-modules/cloud-datastore/google"
  project = var.project_id
  credentials = var.key
# indexes = file(local.index_path_file)
  }

resource "google_cloud_run_service" "todoapp" {
  name     = local.service_name
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.gcp_project_id}/todoapp:latest"
        ports {
          container_port = var.server_port
        }
        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = "roi-takeoff-user62"
        }
      }
    }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.todoapp.location
  project     = google_cloud_run_service.todoapp.project
  service     = google_cloud_run_service.todoapp.name

  policy_data = data.google_iam_policy.noauth.policy_data
}