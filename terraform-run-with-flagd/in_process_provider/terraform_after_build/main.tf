resource "google_service_account" "flagd_sa" {
  account_id   = "flagd-service-account2"
  display_name = "Service Account for Cloud Run with flagd"
}

# Allow cloud run to read from GCS
resource "google_storage_bucket_iam_member" "default_sa_gcs_viewer" {
  bucket = "shun-feature-flags-bucket-test2"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.flagd_sa.email}"
}


resource "google_cloud_run_v2_service" "default" {
    provider = google-beta
    deletion_protection = false
    name     = "shun-flagd-test-in-process"
    location = "us-central1"

    template {
        service_account = google_service_account.flagd_sa.email
        containers {
            image = "us-central1-docker.pkg.dev/shuntestproject1-449502/shun-test-in-process-run-with-flagd/shun-flagd-test-in-process:${var.app_image_tag}"
            volume_mounts {
                name = "gcs-test-volume"
                mount_path = "/gcs/test-volume"
            }
        }

        volumes {
            name = "gcs-test-volume"
            gcs {
                bucket = "shun-feature-flags-bucket-test2"
                read_only = true
                mount_options = [
                    "metadata-cache-ttl-secs=0",
                ]
            }
        }
    }
}