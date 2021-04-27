#!/bin/bash
set -x
set -e

if [[ "$1" != "--nopush" ]]; then
ACCOUNT=$(aws sts get-caller-identity | jq '.Account' -r)
REGION=$AWS_DEFAULT_REGION
if [[ -z "$REGION" ]]; then
    REGION=$AWS_REGION
fi
if [[ -z "$REGION" ]]; then
    REGION=eu-west-2
fi
    URL="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com"
else
    URL="local"
fi

IMAGE_NAME="kidsloop-sfu-manager"
IMAGE_TAG="latest"

echo Build docker image
docker build -t "$URL/$IMAGE_NAME:$IMAGE_TAG" .

if [[ "$1" != "--nopush" ]]; then
    echo Docker login
    aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin "$URL"

    docker push "$URL/$IMAGE_NAME:$IMAGE_TAG"
fi

