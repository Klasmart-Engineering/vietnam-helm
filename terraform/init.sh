#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

PROVIDER=$(../scripts/python/env_var.py  $ENV "provider")
BUCKET=$(../scripts/python/env_var.py  "$ENV" "terraform_bucket")

[ -z "$PROVIDER" ] && echo "Missing variable,'terraform_provider', in $ENV" && exit 1
[ -z "$BUCKET" ] && echo "Missing variable,'terraform_bucket', in $ENV" && exit 1

echo -e "\nPROVIDER:    $PROVIDER\nENVIRONMENT: $ENV\nBUCKET:      $BUCKET"
echo_line

pushd $PROVIDER
rm -rf .terraform
terraform init -upgrade -backend-config="bucket=$BUCKET"
popd