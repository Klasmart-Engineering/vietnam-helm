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
  NS_PERSISTENCE=persistence
fi


DRY_RUN=${DRY_RUN:-"no"}

if [[ $PROVIDER = "vngcloud" ]]; then
  echo -n "Please input MySQL password:"
  while read vngcloud_mysql_password; do
    if [[ ! -z "$vngcloud_mysql_password" ]]; then
      break
    fi
  done
  MYSQL_PASSWORD="$vngcloud_mysql_password"
  echo -n "Please input MySQL root password:"
  while read vngcloud_mysql_root_password; do
    if [[ ! -z "$vngcloud_mysql_root_password" ]]; then
      break
    fi
  done
  MYSQL_ROOT_PASSWORD="$vngcloud_mysql_root_password"
  echo -n "Please input MySQL replication password:"
  while read vngcloud_mysql_replication_password; do
    if [[ ! -z "$vngcloud_mysql_replication_password" ]]; then
      break
    fi
  done
  MYSQL_REP_PASSWORD="$vngcloud_mysql_replication_password"    
else
  MYSQL_PASSWORD="$(pwgen -s 20 1)"
  MYSQL_ROOT_PASSWORD="$(pwgen -s 20 1)"
  MYSQL_REP_PASSWORD="$(pwgen -s 20 1)"
fi  

kubectl create secret generic mysql \
  --dry-run=client \
  -o yaml \
  -n $NS_PERSISTENCE \
  --from-literal=mysql-root-password="$MYSQL_ROOT_PASSWORD" \
  --from-literal=mysql-replication-password="$MYSQL_REP_PASSWORD" \
  --from-literal=mysql-password="$MYSQL_PASSWORD" \
  > mysql-secret.yaml


if [[ "$DRY_RUN" != "yes" ]]; then
  create_namespace_if_not_exists $NS_PERSISTENCE
  create_namespace_if_not_exists "$NS_KIDSLOOP"
  label_namespace_for_redis "$NS_KIDSLOOP"
  kubectl delete secret --ignore-not-found=true -n $NS_PERSISTENCE mysql
  kubectl apply -f mysql-secret.yaml
  
  kubectl delete secret --ignore-not-found=true -n $NS_KIDSLOOP mysql
  kubectl get secret mysql --namespace=$NS_PERSISTENCE -o yaml | \
    sed "s/namespace: $NS_PERSISTENCE/namespace: $NS_KIDSLOOP/" | \
    kubectl apply --namespace=$NS_KIDSLOOP -f -
 
else
  echo "Would run:"
  echo "  kubectl delete secret -n $NS_PERSISTENCE mysql"
  echo "  kubectl apply -f mysql-secret.yaml"
fi

rm mysql-secret.yaml
