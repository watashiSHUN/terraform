# main.tf

resource "google_workflows_workflow" "hello_world_workflow" {
  name            = "hello-world-workflow"
  project         = local.project_id
  region          = local.region
  description     = "A simple 'Hello, World' workflow."

  lifecycle {
    ignore_changes = [
      name,
      source_contents,
    ]
  }

  source_contents = <<-EOT
- create_message:
    call: http.post
    args:
        url: https://webhook.site/#!/62b5d495-9279-4d6d-b895-78e723326759/d40d463e-3248-430c-87d4-e69e0618451c/
        body:
            message: "Hello, World!"
    result: post_result

EOT
}