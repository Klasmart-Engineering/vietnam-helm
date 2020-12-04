#!/bin/bash 
set -e

ENV=$1
JSON=env/${ENV}.json

if [ ! -f $JSON ]; then
    echo "Please set a correct ENV parameter"
    exit 1
fi

cd terraform
terraform init -var-file=env/${ENV}.json
