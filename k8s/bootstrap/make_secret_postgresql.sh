#!/bin/bash
set -e
source ../../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

NS_KIDSLOOP=$(../../scripts/python/env_var.py $ENV $ENUM_NS_KIDSLOOP_VAR)
[ -z "$NS_KIDSLOOP" ] && echo "Missing variable,'$ENUM_NS_KIDSLOOP_VAR', in $ENV" && exit 1

PROVIDER=$(../../scripts/python/env_var.py $ENV "provider")
if [[ $PROVIDER = "gcp" ]]; then
  NS_PERSISTENCE=config-connector
else
  NS_PERSISTENCE=$(../../scripts/python/env_var.py $ENV $ENUM_NS_PERSISTENCE_VAR)
  [ -z "$NS_PERSISTENCE" ] && echo "Missing variable,'$ENUM_NS_PERSISTENCE_VAR', in $ENV" && exit 1
fi


DRY_RUN=${DRY_RUN:-"no"}

kubectl create secret generic postgresql \
  --dry-run=client \
  -o yaml \
  -n $NS_PERSISTENCE \
  --from-literal=postgresql-password="$(pwgen -s 20 1)" \
  --from-literal=repmgr-password="$(pwgen -s 20 1)" > postgresql-secret.yaml


if [[ "$DRY_RUN" != "yes" ]]; then
  create_namespace_if_not_exists $NS_PERSISTENCE
  create_namespace_if_not_exists $NS_KIDSLOOP
  label_namespace_for_redis "$NS_KIDSLOOP"
  kubectl delete secret --ignore-not-found=true -n $NS_PERSISTENCE postgresql
  kubectl apply -f postgresql-secret.yaml
  
  kubectl delete secret --ignore-not-found=true -n $NS_KIDSLOOP postgresql
  kubectl get secret postgresql --namespace=$NS_PERSISTENCE -o yaml | \
    sed "s/namespace: $NS_PERSISTENCE/namespace: $NS_KIDSLOOP/" | \
    kubectl apply --namespace=$NS_KIDSLOOP -f -
  
else
  echo "Would run:"
  echo "  kubectl delete secret -n $NS_PERSISTENCE postgresql"
  echo "  kubectl apply -f postgresql-secret.yaml"
fi

rm postgresql-secret.yaml
