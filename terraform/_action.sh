#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

PROVIDER=$(../scripts/python/env_var.py $ENV "provider")
TFVARS=$(tfvars_path $ENV)

[ -z "$PROVIDER" ] && echo "Missing variable,'provider', in $ENV" && exit 1

echo -e "\nPROVIDER:    $PROVIDER\nENVIRONMENT: $ENV\nTFVARS:      $ENUM_TERRAFORM_VAR_FILE"
echo_line
pushd $PROVIDER
./bootstrap.sh $ENV
echo -e "\nTERRAFORM\n"
terraform $ACTION -var-file="$TFVARS"
popd