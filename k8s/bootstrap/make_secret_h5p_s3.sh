#!/bin/bash
set -e
source ../../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

NS_KIDSLOOP=$(../../scripts/python/env_var.py $ENV $ENUM_NS_KIDSLOOP_VAR)

echo -n "Access Key ID: "
while read access_key_id; do
  if [[ ! -z "$access_key_id" ]]; then
    break
  fi
done

echo -n "Secret Access Key: "
while read secret_access_key; do
  if [[ ! -z "$secret_access_key" ]]; then
    break
  fi
done

kubectl create secret generic h5p-s3-secret \
  --dry-run=client \
  -o yaml \
  -n $NS_KIDSLOOP \
  --from-literal=aws-access-key-id="$access_key_id" \
  --from-literal=aws-secret-access-key="$secret_access_key" \
  > h5p-s3-secret.yaml

if [[ "$DRY_RUN" != "yes" ]]; then
  create_namespace_if_not_exists $NS_KIDSLOOP
  label_namespace_for_redis "$NS_KIDSLOOP"

  kubectl delete secret --ignore-not-found=true -n $NS_KIDSLOOP h5p-s3-secret
  kubectl apply -f h5p-s3-secret.yaml
  
else
  echo "Would run:"
  echo "  kubectl apply -f h5p-s3-secret.yaml"
fi

rm h5p-s3-secret.yaml

