# In your CI/CD pipeline after building and pushing the image:
# 1. Get the current Git commit SHA or a unique build ID
#export IMAGE_TAG=$(git rev-parse HEAD) # Example using Git SHA
# OR
export IMAGE_TAG=$(date +%Y%m%d%H%M%S) # Example using timestamp
export PROJECT_ID="shuntestproject1-449502"

export REGION="us-central1"
export REPO_NAME="cloud-run-docker-repo"
export SERVICE_NAME="flask-hello-world"

# 1. Create repository, if its not done

# 2. Build and push your Docker image with this tag
# TODO(shunxian): I don't need auth to push to artifact repository?
docker build -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${SERVICE_NAME}:${IMAGE_TAG} .
docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${SERVICE_NAME}:${IMAGE_TAG}

# 3. Run Terraform, passing the new tag
cd terraform
terraform init
terraform apply -var="app_image_tag=${IMAGE_TAG}" -auto-approve
