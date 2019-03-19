#!/bin/bash
# Helper script for working with Docker image and container.

# Variables
IMAGE_NAME="chaturvedisulabh/simple-go-webserver"
CONTAINER_NAME="simple-go-webserver"
AWS_REGION="us-east-1"
REPOSITORY_PATH="033623072226.dkr.ecr.us-east-1.amazonaws.com" #TODO: set this to the path of your ECS repository
FULLY_QUALIFIED_IMAGE_NAME="$REPOSITORY_PATH/$IMAGE_NAME"
HOST_PORT=80
CONTAINER_PORT=80
IMAGE_VERSION=`v1.0`

# Builds the Docker image and tags it with latest version number.
buildImage () {
    echo Building Image Version: $IMAGE_VERSION ...
    docker build -t $IMAGE_NAME:latest -t $IMAGE_NAME:$IMAGE_VERSION ./
    echo Build complete.
}

# Runs the container locally.
runContainer () {
    docker run --rm \
        --name $CONTAINER_NAME \
        -p $HOST_PORT:$CONTAINER_PORT \
        -e "ENV=development" \
        -d $IMAGE_NAME
    echo Container started. Open browser at http://localhost:$HOST_PORT .
}

# Pushes the latest version of the image both with the `latest` and specific version tags
pushImage () {
    docker tag $IMAGE_NAME:latest $FULLY_QUALIFIED_IMAGE_NAME:latest
    docker tag $IMAGE_NAME:$IMAGE_VERSION $FULLY_QUALIFIED_IMAGE_NAME:$IMAGE_VERSION
    eval "$(aws ecr get-login --no-include-email --region $AWS_REGION)"
    docker push $FULLY_QUALIFIED_IMAGE_NAME:latest
    docker push $FULLY_QUALIFIED_IMAGE_NAME:$IMAGE_VERSION
}

createRepo () {
    aws ecr create-repository --repository-name $IMAGE_NAME
    echo Created ECR repository: $IMAGE_NAME.
}

# Shows the usage for the script.
showUsage () {
    echo "Description:"
    echo "    Builds, runs and pushes Docker image '$IMAGE_NAME'."
    echo ""
    echo "Options:"
    echo "    build: Builds a Docker image ('$IMAGE_NAME')."
    echo "    run: Runs a container based on an existing Docker image ('$IMAGE_NAME')."
    echo "    buildrun: Builds a Docker image and runs the container."
    echo "    createrepo: Creates new ECR repo called '$IMAGE_NAME'"
    echo "    push: Pushs the image '$IMAGE_NAME' to an image repository"
    echo ""
    echo "Example:"
    echo "    ./docker-task.sh build"
    echo ""
    echo "    This will:"
    echo "        Build a Docker image named $IMAGE_NAME."
}

if [ $# -eq 0 ]; then
  showUsage
else
  case "$1" in
      "build")
             buildImage
             ;;
      "run")
             runContainer
             ;;
      "buildpush")
             buildImage
             pushImage
             ;;
      "push")
             pushImage
             ;;
      "createrepo")
             createRepo
             ;;
      "buildrun")
             buildImage
             runContainer
             ;;
      *)
             showUsage
             ;;
  esac
fi