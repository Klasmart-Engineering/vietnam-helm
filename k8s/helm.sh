#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
CMD=${2:-apply}
env_validate "$ENV"

# if the 2nd arg starts with a dash, it means the helm command is skipped and a flag
# e.g. `--release=*` is used in its place. We also default the helm cmd to `apply` in this case
[[ $CMD == -* ]] && CMD="apply"

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
python3 ../scripts/python/env_all_yaml.py $ENV

# build up some useful helmfile flags
RELEASES_FLAG=""
SKIPDEPS_FLAG=""

for VAR in "$@"; do
    case $VAR in
        --release=*  ) RELEASES_FLAG="$RELEASES_FLAG --selector name=`echo $VAR | cut -d "=" -f2`" ;;
        --skip-deps* ) SKIPDEPS_FLAG="--skip-deps" ;;
    esac
done

# Helm
echo -e "\nRunning Helm"
echo "helmfile command: $CMD"
[[ ! -z "$RELEASES_FLAG" ]] && echo "helmfile selector(s): $RELEASES_FLAG"
[[ ! -z "$SKIPDEPS_FLAG" ]] && echo "helmfile skipping dependencies (--skip-deps): yes"
pushd helm
helmfile -e $ENV $RELEASES_FLAG $CMD $SKIPDEPS_FLAG
popd

#rm $CONFIG_FILE  || true
