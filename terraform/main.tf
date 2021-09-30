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
}


resource "google_project_service" "run" {
  provider = google
  project  = var.project_id  
  service = "run.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "iam" {
  provider = google
  project  = var.project_id  
  service = "iam.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "cloudbuild" {
  provider = google
  project  = var.project_id  
  service = "cloudbuild.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "datastore" {
  provider = google
  project  = var.project_id       
  service = "datastore.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "enable_apigateway_service" {
  provider = google
  project  = var.project_id
  service  = "apigateway.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "resource_manager" {
  provider = google
  project  = var.project_id
  service  = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "service_control" {
  provider = google
  project  = var.project_id
  service  = "servicecontrol.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "service_management" {
  provider = google
  project  = var.project_id
  service  = "servicemanagement.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "apis" {
  provider = google
  project  = var.project_id
  service  = "cloudapis.googleapis.com"
  disable_on_destroy = true
}

resource "google_cloud_run_service" "todoapp" {
  name     = local.service_name
  location = var.region
  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/todoapp:latest"
        ports {
          container_port = var.server_port
        }
        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = var.project_id
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

output "service_url" {
  value = google_cloud_run_service.todoapp.status[0].url
}
