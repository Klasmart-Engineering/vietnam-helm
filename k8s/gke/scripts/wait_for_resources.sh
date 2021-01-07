#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate $ENV

CONFIG=$(cat ../env/$ENV/config.json)
MYSQL_NAME=$(echo $CONFIG | jq -r '.gcp .mysql .name')
MYSQL_USER=$(echo $CONFIG | jq -r '.gcp .mysql .user')
POSTGRESQL_NAME=$(echo $CONFIG | jq -r '.gcp .postgresql .name')
POSTGRESQL_USER=$(echo $CONFIG | jq -r '.gcp .postgresql .user')
REDIS_NAME=$(echo $CONFIG | jq -r '.gcp .redis .name')

kubectl --namespace config-connector wait --for=condition=READY sqlinstance $MYSQL_NAME --timeout 300s
kubectl --namespace config-connector wait --for=condition=READY sqldatabase $MYSQL_NAME --timeout 300s
kubectl --namespace config-connector wait --for=condition=READY sqluser $MYSQL_USER --timeout 300s
kubectl --namespace config-connector wait --for=condition=READY sqlinstance $POSTGRESQL_NAME --timeout 300s
kubectl --namespace config-connector wait --for=condition=READY sqldatabase $POSTGRESQL_NAME --timeout 300s
kubectl --namespace config-connector wait --for=condition=READY sqluser $POSTGRESQL_USER --timeout 300s
kubectl --namespace config-connector wait --for=condition=READY redisinstance $REDIS_NAME --timeout 300s
kubectl --namespace config-connector wait --for=condition=READY computebackendbucket  --timeout 300s
kubectl --namespace config-connector wait --for=condition=READY storagebucket --timeout 300s