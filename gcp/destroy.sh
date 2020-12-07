#!/bin/bash 
set -e

ENV=$1
JSON=env/${ENV}/terraform.json

if [ ! -f $JSON ]; then
    echo "Please set a correct ENV parameter"
    exit 1
fi

cd terraform
terraform destroy -var-file=../env/${ENV}/terraform.json
