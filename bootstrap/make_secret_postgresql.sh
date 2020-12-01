#!/bin/bash
set -xeuo pipefail

DRY_RUN=${DRY_RUN:-"no"}

kubectl create secret generic postgresql \
  --dry-run=client \
  -o yaml \
  -n persistence \
  --from-literal=postgresql-password="$(pwgen -s 20 1)" \
  --from-literal=postgresql-postgres-password="$(pwgen -s 20 1)" \
  --from-literal=repmgr-password="$(pwgen -s 20 1)" > postgresql-secret.yaml

echo "Created new secret:"
#cat postgresql-secret.yaml

if [[ "$DRY_RUN" != "yes" ]]; then
  kubectl delete secret -n persistence postgresql
  kubectl delete secret -n okc postgresql
  kubectl apply -f postgresql-secret.yaml
  kubectl get secret postgresql --namespace=persistence -o yaml | \
    awk '{gsub(/namespace: persistence/,"namespace: okc")}1' | \
    kubectl apply --namespace=okc -f -
else
  echo "Would run:"
  echo "  kubectl delete secret -n persistence postgresql"
  echo "  kubectl apply -f postgresql-secret.yaml"
fi

