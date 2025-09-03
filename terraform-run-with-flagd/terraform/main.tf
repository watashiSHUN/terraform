# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Deploy the Cloud Run service
resource "google_cloud_run_v2_service" "flask_hello_world" {
  name     = var.service_name
  location = var.region
  project  = var.project_id

  template {
    # ingress container
    containers {
      image = "${google_artifact_registry_repository.docker_repo.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${var.service_name}:${var.app_image_tag}"
      ports {
        container_port = 8080
      }
      # Ensure Flask app starts after flagd
      depends_on = ["flagd-sidecar"]
    }
    containers {
      name  = "flagd-sidecar" # Name for the flagd sidecar container
      # GitHub Container Registry
      # image = "ghcr.io/open-feature/flagd:latest" # Official flagd image
      image = "${google_artifact_registry_repository.ghcr_remote_repo.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.ghcr_remote_repo.repository_id}/open-feature/flagd:latest"
      # NOTE: sidecar cannot have exposed port...https://screenshot.googleplex.com/4HoHSZwxGCqtNZu

      args = [
      "start",
      "--port", "8013", 
      "--uri", "gs://${google_storage_bucket.flags_bucket.name}/demo.flagd.json", # Point to your GCS file
      # "--interval", "60s" # Optional: Poll GCS for updates every 60 seconds
      ]

      startup_probe {
        # Using a TCP socket probe since flagd listens on a port (8013)
        tcp_socket {
          port = 8013 # The port flagd listens on internally
        }
        # Optional: Adjust these values based on how long flagd takes to start
        initial_delay_seconds = 5  # Wait 5 seconds before first probe
        period_seconds        = 5  # Check every 5 seconds
        timeout_seconds       = 3  # Timeout if probe doesn't respond in 3 seconds
        failure_threshold     = 6  # Fail after 6 consecutive failures (total 30s + initial delay)
      }

      # Optional: configure flagd arguments, e.g., to load flags from a specific source
      # args = ["--sources", "file:/flags/my-flags.json"]
      # volumes {
      #   name = "flag-config"
      #   mount_path = "/flags"
      # }
    }
  }

  traffic {
    type = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  # lifecycle {
  #   ignore_changes = [
  #     template[0].containers[0].image, # Ignore changes to image to allow manual updates or CI/CD to handle it
  #   ]
  # }

  depends_on = [google_project_service.run_api]
}