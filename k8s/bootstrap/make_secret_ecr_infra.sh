#!/bin/bash
set +xeuo pipefail

source ../../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

NS_KIDSLOOP=$(../../scripts/python/env_var.py $ENV $ENUM_NS_KIDSLOOP_VAR)
[ -z "$NS_KIDSLOOP" ] && echo "Missing variable,'$ENUM_NS_KIDSLOOP_VAR', in $ENV" && exit 1

export AWS_DEFAULT_REGION=eu-west-2
export AWS_ACCESS_KEY_ID=$(kubectl get secret -n $NS_KIDSLOOP ecr-credentials-infra-pull -o jsonpath='{.data.aws_access_key_id}' | base64 --decode)
export AWS_SECRET_ACCESS_KEY=$(kubectl get secret -n $NS_KIDSLOOP ecr-credentials-infra-pull -o jsonpath='{.data.secret_access_key}' | base64 --decode)

kubectl create secret docker-registry ecr-registry-infra \
    --dry-run=client \
    -o yaml \
    -n $NS_KIDSLOOP \
    --docker-server="942095822719.dkr.ecr.eu-west-2.amazonaws.com" \
    --docker-username=AWS \
    --docker-password="$(aws ecr get-login-password)" \
    --docker-email="foo@bar.com" > ecr-secret.yaml

kubectl delete secret --ignore-not-found=true -n $NS_KIDSLOOP ecr-registry-infra
kubectl apply -f ecr-secret.yaml 

rm ecr-secret.yaml
