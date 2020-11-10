#!/bin/bash

#
# This script expects aws-cli-v2 to be installed.
# It will not work with aws-cli v1.18
#

SECRET_NAME=ecr-registry
TOKEN=$(aws ecr get-login-password)
ACCOUNT=$(aws sts get-caller-identity | jq '.Account' -r)
REGION=$AWS_DEFAULT_REGION
if [[ -z "$REGION" ]]; then
    REGION=$AWS_REGION
fi
if [[ -z "$REGION" ]]; then
    REGION=ap-northeast-2
fi

echo "ENV variables setup done."
kubectl create secret docker-registry $SECRET_NAME \
    --dry-run \
    -o yaml \
    -n okc \
    --docker-server="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com" \
    --docker-username=AWS \
    --docker-password="${TOKEN}" \
    --docker-email="foo@bar.com" > ecr-secret.yaml

