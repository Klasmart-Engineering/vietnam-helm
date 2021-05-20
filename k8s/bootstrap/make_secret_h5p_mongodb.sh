#!/bin/bash
set -e
source ../../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

NS_KIDSLOOP=$(../../scripts/python/env_var.py $ENV $ENUM_NS_KIDSLOOP_VAR)
[ -z "$NS_KIDSLOOP" ] && echo "Missing variable,'$ENUM_NS_KIDSLOOP_VAR', in $ENV" && exit 1

DRY_RUN=${DRY_RUN:-"no"}

MONGODB_PASSWORD="$(pwgen -s 20 1)"

kubectl create secret generic h5p-mongodb-secret \
  --dry-run=client \
  -o yaml \
  -n $NS_KIDSLOOP \
  --from-literal=mongodb-password="$MONGODB_PASSWORD" \
  > h5p-mongodb-secret.yaml


if [[ "$DRY_RUN" != "yes" ]]; then
  create_namespace_if_not_exists $NS_KIDSLOOP
  label_namespace_for_redis "$NS_KIDSLOOP"

  # cat h5p-mongodb-secret.yaml
  kubectl delete secret --ignore-not-found=true -n $NS_KIDSLOOP h5p-mongodb-secret
  kubectl apply -f h5p-mongodb-secret.yaml
  
else
  echo "Would run:"
  echo "  kubectl apply -f h5p-mongodb-secret.yaml"
fi

rm h5p-mongodb-secret.yaml
