#!/bin/bash
set -x
set -e

ACCOUNT=$(aws sts get-caller-identity | jq '.Account' -r)
REGION=$AWS_DEFAULT_REGION
if [[ -z "$REGION" ]]; then
    REGION=$AWS_REGION
fi
if [[ -z "$REGION" ]]; then
    REGION=ap-northeast-2
fi
URL="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com"

echo Build docker image
docker build -t $URL/vietnam-sfu-manager:latest .

echo Docker login
aws ecr get-login-password | docker login --username AWS --password-stdin $URL

docker push $URL/vietnam-sfu-manager:latest

