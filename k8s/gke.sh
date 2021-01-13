#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate $ENV

TFOUTPUT_FILE=$(env_path $ENV ".gcp-terraform-output.json")
GKE_FILE=$(env_path $ENV ".gcp-config-connnector.json")
CONFIG_FILE=$(env_path $ENV ".env.yaml")

# Write TFOUTPUT file
echo -e "\nWRITING TFOUTPUT FILE"
pushd ../terraform
TFOUTPUT=$(./output.sh $ENV)
echo -e $TFOUTPUT > $TFOUTPUT_FILE
popd

# Update config connector
echo -e "\n\nUPDATING CONFIG CONNECTOR" && echo_line
gke/scripts/bootstrap_config_connector.sh $TFOUTPUT_FILE

# Delete default network (if exists)
echo -e "\n\nDELETING DEFAULT NETWORK AND DEFAULT FIREWALL RULES" && echo_line
gke/scripts/delete_default_network.sh $TFOUTPUT_FILE

# Create single yaml env file
echo -e "\nCOMBINING ENV CONFIGURATION INTO A SINGLE YAML FILE" && echo_line
../scripts/python/env_all_yaml.py $ENV

# Helm
echo -e "\n\nRUNNING HELM" && echo_line
pushd gke
helmfile -e $ENV apply
popd

# Wait for GKE resources
echo -e "\n\nWATING FOR RESOURCES TO BECOME READY" && echo_line
gke/scripts/wait_for_resources.sh $ENV

# Write GKE file and rewrite all YAML file
echo -e "\n\nWRITING GKE CONFIG FILE: $GKE_FILE" && echo_line
GKE=$(gke/scripts/generate_gke_env.sh $ENV)
echo -e $GKE > $GKE_FILE
../scripts/python/env_all_yaml.py $ENV

# For future use - K8s 1.19 supports Ingress with GCP Storage bucket backend
#echo -e "\n\nFILLING STATIC BUCKETS" && echo_line
#gke/scripts/fill_buckets.sh $ENV

# Leave files in place for main Helm run - to override default vars in helmfiles
