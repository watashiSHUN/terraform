export IMAGE_TAG=$(date +%Y%m%d%H%M%S) # Example using timestamp

docker build -t us-central1-docker.pkg.dev/shuntestproject1-449502/shun-test-in-process-run-with-flagd/shun-flagd-test-in-process:${IMAGE_TAG} .
docker push us-central1-docker.pkg.dev/shuntestproject1-449502/shun-test-in-process-run-with-flagd/shun-flagd-test-in-process:${IMAGE_TAG}

cd terraform_after_build
terraform init
terraform apply -var="app_image_tag=${IMAGE_TAG}" -auto-approve