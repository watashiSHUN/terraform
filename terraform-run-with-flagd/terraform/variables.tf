variable "project_id" {
  description = "The ID of your GCP project."
  type        = string
  default     = "shuntestproject-sandbox-692010"
}

variable "region" {
  description = "The GCP region to deploy resources to."
  type        = string
  default     = "us-central1" # Or your preferred region
}

variable "service_name" {
  description = "The name for the Cloud Run service."
  type        = string
  default     = "flask-hello-world"
}

variable "artifact_registry_repo_name" {
  description = "The name for the Artifact Registry repository."
  type        = string
  default     = "cloud-run-docker-repo"
}

variable "app_image_tag" {
  description = "The tag for the Docker image."
  type        = string
}