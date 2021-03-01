#!/bin/bash
set +xeuo pipefail

# This script expects aws-cli-v2 to be installed.
# It will not work with aws-cli v1.18

export AWS_DEFAULT_REGION=ap-southeast-1
export AWS_ACCESS_KEY_ID=$(kubectl get secret -n okc ecr-credentials-vn-pull -o jsonpath='{.data.aws_access_key_id}' | base64 --decode)
export AWS_SECRET_ACCESS_KEY=$(kubectl get secret -n okc ecr-credentials-vn-pull -o jsonpath='{.data.secret_access_key}' | base64 --decode)

kubectl create secret docker-registry ecr-registry-vn \
    --dry-run=client \
    -o yaml \
    -n okc \
    --docker-server="242787759841.dkr.ecr.ap-southeast-1.amazonaws.com" \
    --docker-username=AWS \
    --docker-password="$(aws ecr get-login-password)" \
    --docker-email="foo@bar.com" > ecr-secret.yaml

kubectl delete secret --ignore-not-found=true -n okc ecr-registry-vn
kubectl apply -f ecr-secret.yaml 

rm ecr-secret.yaml