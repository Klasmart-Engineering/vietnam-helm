#!/bin/bash
set -xeuo pipefail
source ../../scripts/bash/functions.sh

#
# This script expects aws-cli-v2 to be installed.
# It will not work with aws-cli v1.18
#

REGION=${AWS_REGION:-ap-northeast-2}
export AWS_DEFAULT_REGION=$REGION
echo "Region: $REGION"

SECRET_NAME=${SECRET_NAME:-ecr-registry}
NAMESPACE=${NAMESPACE:-okc}
DRY_RUN=${DRY_RUN:-"no"}

TOKEN=$(aws ecr get-login-password)
ACCOUNT=$(aws sts get-caller-identity | jq '.Account' -r)
echo "ENV variables setup done."

create_namespace_if_not_exists "$NAMESPACE"

kubectl create secret docker-registry $SECRET_NAME \
    --dry-run=client \
    -o yaml \
    -n $NAMESPACE \
    --docker-server="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com" \
    --docker-username=AWS \
    --docker-password="${TOKEN}" \
    --docker-email="foo@bar.com" > ecr-secret.yaml

if [[ "$DRY_RUN" != "yes" ]]; then
  kubectl delete secret --ignore-not-found=true -n $NAMESPACE $SECRET_NAME
  kubectl apply -f ecr-secret.yaml
else
  echo "Would run:"
  echo "  kubectl delete secret -n $NAMESPACE $SECRET_NAME"
  echo "  kubectl apply -f ecr-secret.yaml"
fi

rm ecr-secret.yaml
