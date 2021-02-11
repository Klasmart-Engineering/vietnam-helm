#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
CMD=${2:-apply}
env_validate "$ENV"


PROVIDER=$(../scripts/python/env_var.py $ENV "provider")

if [ "$PROVIDER" = "gcp" ]; then

    # Check that we're logged into the correct GCP project
    CURRENT_GOOGLE_CLOUD_PROJECT=$(gcloud config get-value project)
    EXPECTED_GOOGLE_CLOUD_PROJECT=$(../scripts/python/env_var.py $ENV "terraform_project")
    if [ "$CURRENT_GOOGLE_CLOUD_PROJECT" != "$EXPECTED_GOOGLE_CLOUD_PROJECT" ]; then
        echo "ERROR: Please login to GCP project: $CURRENT_GOOGLE_CLOUD_PROJECT"
        exit 1
    fi

    # Check that we're logged into the correct GKE cluster
    REGION=$(../scripts/python/env_var.py $ENV "terraform_region")
    EXPECTED_CONTEXT="gke_${CURRENT_GOOGLE_CLOUD_PROJECT}_${REGION}_kidsloop"
    CURRENT_CONTEXT=$(kubectl config current-context)
    if [ "$EXPECTED_CONTEXT" != "$CURRENT_CONTEXT" ]; then
        echo "ERROR: Please ensure you are logged into the kidsloop GKE cluster in $CURRENT_GOOGLE_CLOUD_PROJECT"
        exit 1
    fi

fi


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
