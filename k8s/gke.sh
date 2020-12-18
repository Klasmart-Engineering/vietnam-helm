#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate $ENV

TFOUTPUT_FILE=$(env_path $ENV ".gcp-terraform-output.json")
CONFIG_FILE=$(env_path $ENV ".env.yaml")

# Write TFOUTPUT file
pushd ../terraform
TFOUTPUT=$(./output.sh $ENV)
echo -e $TFOUTPUT > $TFOUTPUT_FILE
popd

# Update config connector
gke/scripts/bootstrap_config_connector.sh $TFOUTPUT_FILE

# Enable GCP services
gke/scripts/enable_gcp_services.sh $TFOUTPUT_FILE

# Create single yaml env file
../scripts/python/env_all_yaml.py $ENV

# Helm
echo -e "\nRunning Helm"
pushd gke
helmfile -e $ENV apply
popd

echo -e "\nRemoving:"
rm $TFOUTPUT_FILE
echo " - $TFOUTPUT_FILE"
rm $CONFIG_FILE
echo -e " - $CONFIG_FILE\n"