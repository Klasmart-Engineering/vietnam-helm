#!/bin/bash
set -e
source _functions.sh
source _enum.sh

ENV=$1
env_validate_file "$ENV" "$ENUM_TERRAFORM_INIT_FILE"

PROVIDER=$(env_terraform_init_var "$ENV" "terraform_provider")
BUCKET=$(env_terraform_init_var "$ENV" "terraform_bucket")

[ -z "$PROVIDER" ] && echo "Missing variable,'terraform_provider', in $ENV/$ENUM_TERRAFORM_INIT_FILE" && exit 1
[ -z "$BUCKET" ] && echo "Missing variable,'terraform_bucket', in $ENV/$ENUM_TERRAFORM_INIT_FILE" && exit 1

echo -e "\nPROVIDER:    $PROVIDER\nENVIRONMENT: $ENV\nBUCKET:      $BUCKET\n-----------------------------------------------------------------"
terraform init -backend-config="bucket=$BUCKET" $PROVIDER
