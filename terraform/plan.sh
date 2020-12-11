#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

PROVIDER=$(../scripts/python/get_var.py $ENV "provider")
TFVARS=$(tfvars_path $ENV)

[ -z "$PROVIDER" ] && echo "Missing variable,'terraform_provider', in $ENV" && exit 1

echo -e "\nPROVIDER:    $PROVIDER\nENVIRONMENT: $ENV\nTFVARS:      $ENUM_TERRAFORM_VAR_FILE"
echo_line
terraform plan -var-file="$TFVARS" $PROVIDER

