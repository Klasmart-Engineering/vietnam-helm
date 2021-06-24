#!/bin/bash
set -e
source ../../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

NS_KIDSLOOP=$(../../scripts/python/env_var.py $ENV $ENUM_NS_KIDSLOOP_VAR)
[ -z "$NS_KIDSLOOP" ] && echo "Missing variable,'$ENUM_NS_KIDSLOOP_VAR', in $ENV" && exit 1

DRY_RUN=${DRY_RUN:-"no"}
ELASTICSEARCH_URL=$(../../scripts/python/env_var.py $ENV elasticsearch_url)
ELASTICSEARCH_PASSWORD="$(pwgen -s 20 1)"

kubectl create secret generic elasticsearch \
  --dry-run=client \
  -o yaml \
  -n $NS_KIDSLOOP \
  --from-literal=elasticsearch-url="$ELASTICSEARCH_URL" \
  --from-literal=elasticsearch-password="$ELASTICSEARCH_PASSWORD" \
  > elasticsearch.yaml


if [[ "$DRY_RUN" != "yes" ]]; then
  create_namespace_if_not_exists $NS_KIDSLOOP
  label_namespace_for_redis "$NS_KIDSLOOP"

  # cat elasticsearch.yaml
  kubectl delete secret --ignore-not-found=true -n $NS_KIDSLOOP elasticsearch
  kubectl apply -f elasticsearch.yaml
  
else
  echo "Would run:"
  echo "  kubectl apply -f elasticsearch.yaml"
fi

rm elasticsearch.yaml
