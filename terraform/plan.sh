#!/bin/bash
set -e
source _functions.sh
source _enum.sh

ENV=$1
env_validate_file "$ENV" "$ENUM_TERRAFORM_INIT_FILE"
env_validate_file "$ENV" "$ENUM_TERRAFORM_VAR_FILE"

PROVIDER=$(env_terraform_init_var "$ENV" "terraform_provider")
TFVARS=$(env_path $ENV $ENUM_TERRAFORM_VAR_FILE)

echo_terraform_params $PROVIDER $ENV $ENUM_TERRAFORM_VAR_FILE
terraform plan -var-file="$TFVARS" $PROVIDER

