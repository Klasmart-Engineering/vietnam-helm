#!/bin/bash
set -e
source ../../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

NS_KIDSLOOP=$(../../scripts/python/env_var.py $ENV $ENUM_NS_KIDSLOOP_VAR)
[ -z "$NS_KIDSLOOP" ] && echo "Missing variable,'$ENUM_NS_KIDSLOOP_VAR', in $ENV" && exit 1

MYSQL_HOST=$(../../scripts/python/env_var.py $ENV mysql_host)
PROVIDER=$(../../scripts/python/env_var.py $ENV "provider")
MYSQL_USERNAME=$(../../scripts/python/env_var.py $ENV mysql_username)
MYSQL_DATABASE=$(../../scripts/python/env_var.py $ENV mysql_database)
SECRET_NAME=mysql

if [[ $PROVIDER = "gcp" ]]; then
  NS_PERSISTENCE=config-connector
  MYSQL_HOST=127.0.0.1
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

DATABASE_URL="mysql://$MYSQL_USERNAME:$MYSQL_PASSWORD@$MYSQL_HOST:3306/$MYSQL_DATABASE"

# create k8s secret manifest
kubectl create secret generic $SECRET_NAME \
  --dry-run=client \
  -o yaml \
  --from-literal=mysql-root-password="$MYSQL_ROOT_PASSWORD" \
  --from-literal=mysql-replication-password="$MYSQL_REP_PASSWORD" \
  --from-literal=mysql-password="$MYSQL_PASSWORD" \
  --from-literal=mysql-url="$DATABASE_URL" \
  > $SECRET_NAME.yaml

for namespace in $NS_PERSISTENCE $NS_KIDSLOOP
do
  if [[ "$DRY_RUN" != "yes" ]]; then
    # create namespace if namespace doesn't exist
    create_namespace_if_not_exists $namespace
    if [ $namespace == $NS_KIDSLOOP ]; then label_namespace_for_redis "$NS_KIDSLOOP"; fi

    # create secret if secret doesn't exist
    result=`kubectl -n $namespace get secret --ignore-not-found $SECRET_NAME`
    if [ "$result" ]; then
        echo "Kubernetes secret $SECRET_NAME in namespace $namespace already exists!"
    else
        echo "Creating kubernetes secret $SECRET_NAME in namespace $namespace"
        kubectl -n $namespace apply -f $SECRET_NAME.yaml
    fi
  else
    echo "Would run:"
    echo "  kubectl delete secret -n $namespace $SECRET_NAME"
    echo "  kubectl -n $namespace apply -f $SECRET_NAME.yaml"
  fi
done

# remove k8s secret manifest
rm $SECRET_NAME.yaml
