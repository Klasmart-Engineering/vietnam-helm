#!/bin/bash
set -e

NAMESPACE=${NAMESPACE:-okc}

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
  namespace: $NAMESPACE
data:
  credentials: |
$CREDS
EOF

