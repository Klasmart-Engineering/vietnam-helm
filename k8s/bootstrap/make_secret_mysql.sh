#!/bin/bash
set -e
source ../../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

NS_KIDSLOOP=$(../../scripts/python/get_var.py $ENV $ENUM_NS_KIDSLOOP_VAR)
NS_PERSISTENCE=$(../../scripts/python/get_var.py $ENV $ENUM_NS_PERSISTENCE_VAR)

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

if [[ "$DRY_RUN" != "yes" ]]; then
  create_namespace_if_not_exists $NS_PERSISTENCE
  create_namespace_if_not_exists "$NS_KIDSLOOP"
  kubectl delete secret --ignore-not-found=true -n $NS_PERSISTENCE mysql
  kubectl delete secret --ignore-not-found=true -n $NS_KIDSLOOP mysql
  kubectl apply -f mysql-secret.yaml
  kubectl get secret mysql --namespace=$NS_PERSISTENCE -o yaml | \
   sed "s/namespace: $NS_PERSISTENCE/namespace: $NS_KIDSLOOP/" | \
   kubectl apply --namespace=$NS_KIDSLOOP -f -
   
else
  echo "Would run:"
  echo "  kubectl delete secret -n $NS_PERSISTENCE mysql"
  echo "  kubectl apply -f mysql-secret.yaml"
fi

rm mysql-secret.yaml