#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate $ENV


PROJECT=$(cat ../env/$ENV/tfvars.json | jq -r '.terraform_project')
NAMESPACE=$(cat ../env/$ENV/config.json | jq -r '.k8s_namespace_kidsloop')

gcloud iam service-accounts add-iam-policy-binding \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:$PROJECT.svc.id.goog[$NAMESPACE/cloudsql-proxy]" \
  cloudsql-proxy@$PROJECT.iam.gserviceaccount.com

kubectl annotate serviceaccount -n $NAMESPACE --overwrite=true \
   cloudsql-proxy \
   iam.gke.io/gcp-service-account=cloudsql-proxy@$PROJECT.iam.gserviceaccount.com