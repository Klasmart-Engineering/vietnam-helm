#!/bin/bash 
set -e

ENV=$1
JSON=env/${ENV}/init.json

if [ ! -f $JSON ]; then
    echo "Please set an ENV with appropriate init json file"
    exit 1
fi

BUCKET=$(cat $JSON | jq -r .gcp_terraform_bucket)

cd terraform
terraform init -backend-config="bucket=${BUCKET}"
