#!/bin/bash
set -xeuo pipefail
source "_functions.sh"

DRY_RUN=${DRY_RUN:-"no"}

kubectl create secret generic postgresql \
  --dry-run=client \
  -o yaml \
  -n persistence \
  --from-literal=postgresql-password="$(pwgen -s 20 1)" \
  --from-literal=repmgr-password="$(pwgen -s 20 1)" > postgresql-secret.yaml

echo "Created new secret:"
#cat postgresql-secret.yaml

if [[ "$DRY_RUN" != "yes" ]]; then
  create_namespace_if_not_exists "persistence"
  create_namespace_if_not_exists "okc"
  kubectl delete secret --ignore-not-found=true -n persistence postgresql
  kubectl delete secret --ignore-not-found=true -n okc postgresql
  kubectl apply -f postgresql-secret.yaml
  kubectl get secret postgresql --namespace=persistence -o yaml | \
    awk '{gsub(/namespace: persistence/,"namespace: okc")}1' | \
    kubectl apply --namespace=okc -f -
else
  echo "Would run:"
  echo "  kubectl delete secret -n persistence postgresql"
  echo "  kubectl apply -f postgresql-secret.yaml"
fi

