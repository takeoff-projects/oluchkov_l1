variable "project_id" {
  description = "GCP Project"
  type        = string
  default     = "roi-takeoff-user62"
}

variable "region" {
  description = "GCP region"
  type = string
  default = "us-central1"
}

variable "zone" {
  description = "GCP region timezone"
  type = string
}

variable "key" {
  description = "Path to your service account key json file."
  type = string
  default = "../gcp-sa-key.json"
}

variable "server_port" {
  description = "HTTP server port HTTP"
  type = string
}

variable "db_name" {
  description = "Datastore DB name"
  type = string
}
