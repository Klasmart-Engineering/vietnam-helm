#!/bin/bash
set -x
set -e

build_prep.sh

if [[ "$1" != "--nopush" ]]; then
    ACCOUNT=$(aws sts get-caller-identity | jq '.Account' -r)
    REGION=$AWS_DEFAULT_REGION
    if [[ -z "$REGION" ]]; then
        REGION=$AWS_REGION
    fi
    if [[ -z "$REGION" ]]; then
        REGION=ap-northeast-2
    fi

    URL="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com"
else
    URL="local"
fi

echo Build docker image
docker build -t $URL/vietnam-kl2-static:latest .

if [[ "$1" != "--nopush" ]]; then
    echo Docker login
    aws ecr get-login-password | docker login --username AWS --password-stdin $URL
    docker push $URL/vietnam-kl2-static:latest
fi
