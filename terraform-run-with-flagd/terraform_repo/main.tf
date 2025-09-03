# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Create an Artifact Registry repository for Docker images
resource "google_artifact_registry_repository" "docker_repo" {
  repository_id = var.artifact_registry_repo_name
  format        = "DOCKER"
}

# TODO(shunxian): write a file to stoage
# Reference to the GCS bucket you want flagd to read from
resource "google_storage_bucket" "flags_bucket" {
  name          = "shun-feature-flags-bucket-test1" # Choose a globally unique bucket name
  location      = "us"
  force_destroy = false # Set to true with caution for production
  # Optional: Add uniform_bucket_level_access = true for simplified IAM
  uniform_bucket_level_access = true
}

# Alternatively, if you want to use the default Compute Engine service account
# Data source for the default Compute Engine service account
data "google_compute_default_service_account" "default" {
  project = var.project_id
}

resource "google_storage_bucket_iam_member" "default_sa_gcs_viewer" {
  bucket = google_storage_bucket.flags_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

resource "google_artifact_registry_repository" "ghcr_remote_repo" {
  repository_id = "ghcr-proxy" # Or any name you prefer for your GHCR proxy
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY" # Crucial: set to REMOTE_REPOSITORY
  remote_repository_config {
    docker_repository {
      custom_repository {
        uri = "https://ghcr.io" # The upstream registry URL
      }
    }
  }
}