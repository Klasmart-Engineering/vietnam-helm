#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
CMD=${2:-apply}
env_validate "$ENV"

TFOUTPUT_FILE=$(env_path $ENV ".gcp-terraform-output.json")
CONFIG_FILE=$(env_path $ENV ".env.yaml")

rm $TFOUTPUT_FILE || true

# Create single yaml env file
../scripts/python/env_all_yaml.py $ENV

# Helm
echo -e "\nRunning Helm"
pushd helm
helmfile -e $ENV $CMD
popd

#rm $CONFIG_FILE  || true
