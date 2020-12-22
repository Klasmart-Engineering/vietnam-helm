#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

DOCKER=$2

pushd docker

#if [[ (-z $DOCKER) || "$DOCKER" = "service-hub" ]]
#then
#    pushd service-hub
#     echo_heading "Building HUB service Docker image"
#    ./build.sh
#    popd
#fi

if [[ (-z "$DOCKER")  || "$DOCKER" = "service-sfu-manager" ]]
then
    pushd service-sfu-manager
     echo_heading "Building SFU Manager service Docker image"
    ./build.sh
    popd
fi

if [[ (-z "$DOCKER")  || "$DOCKER" = "service-static" ]]
then
    pushd service-static
     echo_heading "Building Static service Docker image"
    ./build.sh
    popd
fi

if [[ (-z "$DOCKER")  || "$DOCKER" = "service-kl2-static" ]]
then
    pushd service-kl2-static
     echo_heading "Building KL2 Static service Docker image"
    ./build.sh
    popd
fi

if [[ (-z "$DOCKER")  || "$DOCKER" = "cronjob-ecr-token" ]]
then
    pushd cronjob-ecr-token
     echo_heading "Building ECR Token cronjob Docker image"
    ./build.sh
    popd
fi
