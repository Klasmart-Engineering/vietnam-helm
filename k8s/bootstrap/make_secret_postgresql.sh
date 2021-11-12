#!/bin/bash
set -e
source ../../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

NS_KIDSLOOP=$(../../scripts/python/env_var.py $ENV $ENUM_NS_KIDSLOOP_VAR)
[ -z "$NS_KIDSLOOP" ] && echo "Missing variable,'$ENUM_NS_KIDSLOOP_VAR', in $ENV" && exit 1
PROVIDER=$(../../scripts/python/env_var.py $ENV provider)

POSTGRESQL_HOST=$(../../scripts/python/env_var.py $ENV postgresql_host)
POSTGRESQL_USERNAME=$(../../scripts/python/env_var.py $ENV postgresql_username)
POSTGRESQL_USER_DATABASE=$(../../scripts/python/env_var.py $ENV postgresql_database)
POSTGRESQL_ASSESSMENT_DATABASE=$(../../scripts/python/env_var.py $ENV postgresql_assessment_database)
POSTGRESQL_ATTENDANCE_DATABASE=$(../../scripts/python/env_var.py $ENV postgresql_attendance_database)
SECRET_NAME=postgresql
REPMGR_PASSWORD="$(pwgen -s 20 1)"

if [[ $PROVIDER = "gcp" ]]; then
  NS_PERSISTENCE=config-connector
  POSTGRESQL_HOST=127.0.0.1
else
  NS_PERSISTENCE=persistence
fi

DRY_RUN=${DRY_RUN:-"no"}

if [[ $PROVIDER = "vngcloud" ]]; then
  echo -n "Please input postgresql password:"
  while read vngcloud_postgresql_password; do
    if [[ ! -z "$vngcloud_postgresql_password" ]]; then
      break
    fi
  done
  POSTGRESQL_PASSWORD="$vngcloud_postgresql_password"
else
  POSTGRESQL_PASSWORD="$(pwgen -s 20 1)"
fi  

DATABASE_URL="postgres://$POSTGRESQL_USERNAME:$POSTGRESQL_PASSWORD@$POSTGRESQL_HOST"
DATABASE_USER_URL="$DATABASE_URL/$POSTGRESQL_USER_DATABASE"
DATABASE_ASSESSMENT_URL="$DATABASE_URL/$POSTGRESQL_ASSESSMENT_DATABASE"
DATABASE_ATTENDANCE_URL="$DATABASE_URL/$POSTGRESQL_ATTENDANCE_DATABASE"

# create k8s secret manifest
kubectl create secret generic $SECRET_NAME \
  --dry-run=client \
  -o yaml \
  --from-literal=postgresql-password="$POSTGRESQL_PASSWORD" \
  --from-literal=database-url="$DATABASE_USER_URL" \
  --from-literal=assessment-database-url="$DATABASE_ASSESSMENT_URL" \
  --from-literal=repmgr-password="$(pwgen -s 20 1)" > $SECRET_NAME.yaml

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
