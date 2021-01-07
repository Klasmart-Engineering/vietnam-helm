#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate $ENV

PROJECT=$(cat ../env/$ENV/tfvars.json | jq -r '.terraform_project')

pushd docker/service-kl2-static
./build_prep.sh $ENV
gsutil -m rsync -r -d cms-frontend-web/build gs://$PROJECT-service-kl2-static-cdn/
popd

