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

create_namespace_if_not_exists "$NS_KIDSLOOP"

CREDS=$(cat <<EOF | base64 | sed 's/^/    /g'
[default]
aws_access_key_id = $access_key_id
aws_secret_access_key = $secret_access_key
EOF
)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: cms-backend-s3-secret
  namespace: $NS_KIDSLOOP
data:
  credentials: |
$CREDS
EOF

