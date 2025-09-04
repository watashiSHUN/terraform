# Configure the Google Cloud provider
provider "google" {
  project = "shuntestproject1-449502"
  region  = "us-central1"
}

# Create an Artifact Registry repository for Docker images
resource "google_artifact_registry_repository" "docker_repo" {
  repository_id = "shun-test-in-process-run-with-flagd"
  format        = "DOCKER"
}

# Reference to the GCS bucket you want flagd to read from
resource "google_storage_bucket" "flags_bucket" {
  name          = "shun-feature-flags-bucket-test2" # Choose a globally unique bucket name
  location      = "us"
  force_destroy = false # Set to true with caution for production
  # Optional: Add uniform_bucket_level_access = true for simplified IAM
  uniform_bucket_level_access = true
}

# Upload flag definition to blob storage
resource "google_storage_bucket_object" "default" {
 name         = "demo_flag_definition_json"
 source       = "../flags.json"
 content_type = "application/json"
 bucket       = google_storage_bucket.flags_bucket.id
}