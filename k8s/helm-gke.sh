#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

TFOUTPUT_FILE=$(env_path $ENV ".gcp-terraform-output.json")
CONFIG_FILE=$(env_path $ENV "env.yaml")

pushd ../terraform
TFVARS=$(./output.sh $ENV)
popd

echo $TFVARS > $TFOUTPUT_FILE
CONFIG=$(../scripts/python/env_all_yaml.py $ENV)
rm $TFOUTPUT_FILE
echo -e $CONFIG > $CONFIG_FILE

#pushd helm-gke
#helmfile -e $ENV -f $CONFIG_FILE apply
#popd

