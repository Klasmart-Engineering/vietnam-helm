#!/bin/bash
set -e

TFOUTPUT=$1
SERVICE_ACCOUNT=$(cat $TFOUTPUT | jq -r '.service_account_config_connector .value')

echo -e "Setting config connector service account to: $SERVICE_ACCOUNT"

cat << EOF > .config_connector.yaml
# configconnector.yaml
apiVersion: core.cnrm.cloud.google.com/v1beta1
kind: ConfigConnector
metadata:
  # the name is restricted to ensure that there is only one
  # ConfigConnector instance installed in your cluster
  name: configconnector.core.cnrm.cloud.google.com
spec:
 mode: cluster
 googleServiceAccount: "${SERVICE_ACCOUNT}"
EOF
echo " - wrote .config_connector.yaml"

kubectl apply -f .config_connector.yaml
echo " - applied .config_connector.yaml"

rm .config_connector.yaml
echo -e " - removed .config_connector.yaml"