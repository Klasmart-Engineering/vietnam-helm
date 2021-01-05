#!/bin/bash
set -e
source ../../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

PROJECT=$(../../scripts/python/env_var.py $ENV "terraform_project")
[ -z "$PROJECT" ] && echo "Missing variable,'terraform_project', in $ENV" && exit 1

echo "PROJECT: $PROJECT"
echo_line
echo -e "\nBOOTSTRAP\n"
echo -e "Enabling Google Services"

gcloud services enable --project $PROJECT \
  servicenetworking.googleapis.com \
  servicemanagement.googleapis.com \
  iamcredentials.googleapis.com \
  cloudkms.googleapis.com \
  compute.googleapis.com \
  container.googleapis.com \
  redis.googleapis.com \
  sqladmin.googleapis.com

  