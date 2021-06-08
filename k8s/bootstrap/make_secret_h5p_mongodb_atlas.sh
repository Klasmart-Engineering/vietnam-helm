# This secret is used by mongodb atlas helm chart
# The secret has to have the following name structure: <ATLAS_PROJECT_NAME>-<ATLAS_CLUSTER_NAME>-<ATLAS_DB_USERNAME>
# Eg: Secret name is mongodb-atlas-cluster-kidslooproot, where username is kidslooproot

#!/bin/bash
set -e
source ../../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

NS_KIDSLOOP=$(../../scripts/python/env_var.py $ENV $ENUM_NS_KIDSLOOP_VAR)
[ -z "$NS_KIDSLOOP" ] && echo "Missing variable,'$ENUM_NS_KIDSLOOP_VAR', in $ENV" && exit 1

SECRET_NAME=mongodb-atlas-cluster-kidslooproots

# create kubernetes secret if it doesn't exist yet
result=`kubectl -n okc get secret --ignore-not-found $SECRET_NAME`
if [ "$result" ]; then
    echo "Kubernetes secret $KUBERNETES_SECRET already exists!"
else
    echo "Creating kubernetes secret $KUBERNETES_SECRET"
    MONGODB_ATLAS_USER_PASSWORD="$(pwgen -s 20 1)"
    kubectl create secret generic $SECRET_NAME \
      --dry-run=client \
      -o yaml \
      -n $NS_KIDSLOOP \
      --from-literal=password="$MONGODB_ATLAS_USER_PASSWORD" \
      > $SECRET_NAME.yaml
    kubectl apply -f $SECRET_NAME.yaml
    rm $SECRET_NAME.yaml
fi
