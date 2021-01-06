#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate $ENV

TFOUTPUT_FILE=$(env_path $ENV ".gcp-terraform-output.json")
GKE_FILE=$(env_path $ENV ".gcp-config-connnector.json")
CONFIG_FILE=$(env_path $ENV ".env.yaml")


# Write TFOUTPUT file
pushd ../terraform
TFOUTPUT=$(./output.sh $ENV)
echo -e $TFOUTPUT > $TFOUTPUT_FILE
popd

# Update config connector
gke/scripts/bootstrap_config_connector.sh $TFOUTPUT_FILE

# Delete default network (if exists)
gke/scripts/delete_default_network.sh $TFOUTPUT_FILE

# Create single yaml env file
../scripts/python/env_all_yaml.py $ENV

# Helm
echo -e "\nRunning Helm"
pushd gke
helmfile -e $ENV apply
popd

# Write GKE file and rewrite all YAML file
GKE=$(gke/scripts/generate_gke_env.sh $ENV)
echo -e $GKE > $GKE_FILE
../scripts/python/env_all_yaml.py $ENV

# Leave files in place for main Helm run - to override default vars in helmfiles
