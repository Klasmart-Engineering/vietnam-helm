#!/bin/bash
set -e
source ../../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

NS_KIDSLOOP=$(../../scripts/python/env_var.py $ENV $ENUM_NS_KIDSLOOP_VAR)
NS_PERSISTENCE=$(../../scripts/python/env_var.py $ENV $ENUM_NS_PERSISTENCE_VAR)
PROVIDER=$(../../scripts/python/env_var.py $ENV "provider")

[ -z "$NS_KIDSLOOP" ] && echo "Missing variable,'$ENUM_NS_KIDSLOOP_VAR', in $ENV" && exit 1
[ -z "$NS_PERSISTENCE" ] && echo "Missing variable,'$ENUM_NS_PERSISTENCE_VAR', in $ENV" && exit 1

DRY_RUN=${DRY_RUN:-"no"}

kubectl create secret generic mysql \
  --dry-run=client \
  -o yaml \
  -n $NS_PERSISTENCE \
  --from-literal=mysql-root-password="$(pwgen -s 20 1)" \
  --from-literal=mysql-replication-password="$(pwgen -s 20 1)" \
  --from-literal=mysql-password="$(pwgen -s 20 1)" \
  > mysql-secret.yaml


function copy_secret {
  NEW_NAMESPACE=$1
  create_namespace_if_not_exists "$NEW_NAMESPACE"
  kubectl delete secret --ignore-not-found=true -n $NEW_NAMESPACE mysql
  kubectl get secret mysql --namespace=$NS_PERSISTENCE -o yaml | \
  sed "s/namespace: $NS_PERSISTENCE/namespace: $NEW_NAMESPACE/" | \
  kubectl apply --namespace=$NEW_NAMESPACE -f -
} 


if [[ "$DRY_RUN" != "yes" ]]; then
  create_namespace_if_not_exists $NS_PERSISTENCE
  kubectl delete secret --ignore-not-found=true -n $NS_PERSISTENCE mysql
  kubectl apply -f mysql-secret.yaml
  copy_secret $NS_KIDSLOOP

  if [[ $PROVIDER = "gcp" ]]; then
    copy_secret config-connector
  fi
   
else
  echo "Would run:"
  echo "  kubectl delete secret -n $NS_PERSISTENCE mysql"
  echo "  kubectl apply -f mysql-secret.yaml"
fi

rm mysql-secret.yaml
