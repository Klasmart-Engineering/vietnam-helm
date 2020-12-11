#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

PROVIDER=$(../scripts/python/get_var.py  $ENV "provider")
BUCKET=$(../scripts/python/get_var.py  "$ENV" "terraform_bucket")
TFVARS=$(tfvars_path $ENV)

[ -z "$PROVIDER" ] && echo "Missing variable,'terraform_provider', in $ENV" && exit 1
[ -z "$BUCKET" ] && echo "Missing variable,'terraform_bucket', in $ENV" && exit 1

echo -e "\nPROVIDER:    $PROVIDER\nENVIRONMENT: $ENV\nBUCKET:      $BUCKET"
echo_line
terraform init -backend-config="bucket=$BUCKET" $PROVIDER
