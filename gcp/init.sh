#!/bin/bash 
set -e

ENV=$1
JSON=env/${ENV}.json

if [ ! -f $JSON ]; then
    echo "Please set a correct ENV parameter"
    exit 1
fi

BUCKET=$(cat env/$ENV.json | jq -r .gcp_terraform_bucket)

cd terraform
terraform init -var-file=env/${ENV}.json -backend-config="bucket=${BUCKET}"
