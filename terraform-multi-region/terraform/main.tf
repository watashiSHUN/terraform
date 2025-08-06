provider "google" {
  project = local.project_id
  region  = local.regions[0] # The default region for provider, can be overridden by resources
}

resource "google_workflows_workflow" "test_dummy_workflow" {
  name        = "test-dummy-workflow"
  project     = local.project_id
  region      = "us-central1"
  description = "A simple dummy workflow for demonstration"
  # This workflow simply logs "Hello, World!"
  source_contents = <<-EOT
    - logMessage:
        call: sys.log
        args:
            text: "Hello from dummy-example-workflow!"
  EOT
  #service_account = "policy-orchestrator@gcure-sandbox.iam.gserviceaccount.com"
  deletion_protection = false
}

# should already be enabled
# resource "google_project_service" "apis" {
#   for_each = toset([
#     "run.googleapis.com",
#     "compute.googleapis.com",
#     "serviceusage.googleapis.com",
#     "artifactregistry.googleapis.com" # Required for deploying container images
#   ])
#   service            = each.key
#   disable_on_destroy = false
# }

# Single artifact registry
resource "google_artifact_registry_repository" "default" {
  project    = local.project_id
  location    = local.regions[0] # Or a region close to your build environment
  repository_id = "cloud-run-app-repo"
  format      = "DOCKER"
  # depends_on  = [google_project_service.apis["artifactregistry.googleapis.com"]]
}

resource "google_cloud_run_v2_service" "hello_world" {
  for_each = toset(local.regions) # note: each.key and each.value are the same for a set
  name     = "hello-world-service-${replace(each.key, "-", "")}"
  location = each.key
  project  = local.project_id
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    containers {
      image = "${google_artifact_registry_repository.default.location}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.default.repository_id}/hello-world:${formatdate("YYYY-MM-DD", timestamp())}"
      env {
        name  = "REGION"
        value = each.key
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  depends_on = [
    google_artifact_registry_repository.default,
    null_resource.docker_build_push # Ensure image is pushed before deployment
  ]
}

# Create a Serverless NEG for each regional Cloud Run service
resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  for_each = toset(local.regions)
  name     = "my-neg-${each.value}"
  region   = each.value
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.hello_world[each.value].name
  }
}

# Create a global backend service
# resource "google_compute_backend_service" "global_backend" {
#   name        = "global-backend-service"
#   protocol    = "HTTP"
#   enable_cdn  = false
#   timeout_sec = 10
# }

# # Add each regional NEG to the global backend service
# resource "google_compute_backend_service_iam_member" "backend_member" {
#   for_each = toset(local.regions)
#   project  = local.project_id
#   backend_service = google_compute_backend_service.global_backend.name
#   role            = "roles/compute.networkUser"
#   member          = "serviceAccount:service-${local.project_id}@gcp-sa-loadbalancer.iam.gserviceaccount.com"
# }

# resource "google_compute_backend_service_iam_policy" "backend_policy" {
#   project  = local.project_id
#   backend_service = google_compute_backend_service.global_backend.name
#   policy_data = data.google_iam_policy.admin.policy_data
# }

# # Add the NEGs to the backend service. This is a crucial step.
# resource "google_compute_backend_service_backend" "backend_neg" {
#   for_each = toset(local.regions)
#   backend_service = google_compute_backend_service.global_backend.name
#   group           = google_compute_region_network_endpoint_group.serverless_neg[each.value].self_link
# }

# Grant public access to the Cloud Run service
# resource "google_cloud_run_v2_service_iam_member" "noauth_cloud_run" {
#   for_each = toset(local.regions)
#   name     = google_cloud_run_v2_service.hello_world[each.key].name
#   location = google_cloud_run_v2_service.hello_world[each.key].location
#   project  = local.project_id
#   role     = "roles/run.invoker"
#   member   = "allUsers"
# }

# Local-exec provisioner to build and push the Docker image
resource "null_resource" "docker_build_push" {
  triggers = {
    # Re-run if Python files or Dockerfile changes
    python_app_hash = filesha256("../app/main.py")
    dockerfile_hash = filesha256("../Dockerfile")
    requirements_hash = filesha256("../app/requirements.txt")
  }


#TODO(shunxian): us-west1-docker.pkg.dev/shuntestproject-sandbox-692010/cloud-run-app-repo/hello-world-2025-07-25' not found
# hello-world:${formatdate("YYYY-MM-DD", timestamp())}
# hello-world is the service_name
# date is the tag name

# us-west1-docker.pkg.dev/shuntestproject-sandbox-692010/cloud-run-app-repo/hello-world:2025-07-26 not found
# us-west1-docker.pkg.dev/shuntestproject-sandbox-692010/cloud-run-app-repo/hello-world@sha256:91d5a853cbb4a7a6fce3f414b84d53da580e4fb8c872de3c7cb759cf7d6836db
  provisioner "local-exec" {
    command = <<-EOT
      cd ..
      docker build -t ${google_artifact_registry_repository.default.location}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.default.repository_id}/hello-world:${formatdate("YYYY-MM-DD", timestamp())} .
      docker push ${google_artifact_registry_repository.default.location}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.default.repository_id}/hello-world:${formatdate("YYYY-MM-DD", timestamp())}
    EOT
    environment = {
      PROJECT_ID = local.project_id
      REGION = google_artifact_registry_repository.default.location
      REPO_ID = google_artifact_registry_repository.default.repository_id
    }
  }

  depends_on = [google_artifact_registry_repository.default]
}