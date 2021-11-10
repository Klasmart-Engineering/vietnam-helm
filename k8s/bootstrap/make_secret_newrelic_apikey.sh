#!/bin/bash
set -e
source ../../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

NS_KIDSLOOP=$(../../scripts/python/env_var.py $ENV $ENUM_NS_KIDSLOOP_VAR)

echo -n "NEW RELIC LICENSE Key: "
while read NEW_RELIC_LICENSE_KEY; do
  if [[ ! -z "$NEW_RELIC_LICENSE_KEY" ]]; then
    break
  fi
done

create_namespace_if_not_exists "$NS_KIDSLOOP"

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: newrelic-apikey-secret
  namespace: $NS_KIDSLOOP
data:
  NEW_RELIC_LICENSE_KEY: $(echo -n $NEW_RELIC_LICENSE_KEY | base64)
EOF

