#!/bin/bash
set -xeuo pipefail
source "_functions.sh"

DRY_RUN=${DRY_RUN:-"no"}

kubectl create secret generic mysql \
  --dry-run=client \
  -o yaml \
  -n persistence \
  --from-literal=mysql-root-password="$(pwgen -s 20 1)" \
  --from-literal=mysql-replication-password="$(pwgen -s 20 1)" \
  --from-literal=mysql-password="$(pwgen -s 20 1)" \
  > mysql-secret.yaml

if [[ "$DRY_RUN" != "yes" ]]; then
  create_namespace_if_not_exists "persistence"
  create_namespace_if_not_exists "okc"
  kubectl delete secret --ignore-not-found=true -n persistence mysql
  kubectl delete secret --ignore-not-found=true -n okc mysql
  kubectl apply -f mysql-secret.yaml
  kubectl get secret mysql --namespace=persistence -o yaml | \
    awk '{gsub(/namespace: persistence/,"namespace: okc")}1' | \
    kubectl apply --namespace=okc -f -
else
  echo "Would run:"
  echo "  kubectl delete secret -n persistence mysql"
  echo "  kubectl apply -f mysql-secret.yaml"
fi

