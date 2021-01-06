#!/bin/bash
set -e
source ../../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

NS_KIDSLOOP=$(../../scripts/python/env_var.py $ENV $ENUM_NS_KIDSLOOP_VAR)
[ -z "$NS_KIDSLOOP" ] && echo "Missing variable,'$ENUM_NS_KIDSLOOP_VAR', in $ENV" && exit 1

if kubectl get secret -n $NS_KIDSLOOP aws-credentials; then
  echo "AWS credentials already exist in cluster"
  exit 0
fi

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
label_namespace_for_redis "$NS_KIDSLOOP"

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
  name: aws-credentials
  namespace: $NS_KIDSLOOP
data:
  credentials: |
$CREDS
EOF

