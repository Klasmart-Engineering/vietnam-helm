#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

CONFIG_FILE=$(config_path $ENV)
PROVIDER=$(cat $CONFIG_FILE | jq -r '.provider')
[ -z "$PROVIDER" ] && echo "Missing variable,'provider', in $ENV" && exit 1

pushd $PROVIDER
terraform output -json
popd
