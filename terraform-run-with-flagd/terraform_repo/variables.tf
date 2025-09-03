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

variable "artifact_registry_repo_name" {
  description = "The name for the Artifact Registry repository."
  type        = string
  default     = "cloud-run-docker-repo"
}