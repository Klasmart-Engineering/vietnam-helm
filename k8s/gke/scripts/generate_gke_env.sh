#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate $ENV

CONFIG=$(cat ../env/$ENV/config.json)
MYSQL_NAME=$(echo $CONFIG | jq -r '.gcp .mysql .name')
POSTGRESQL_NAME=$(echo $CONFIG | jq -r '.gcp .postgresql .name')
REDIS_NAME=$(echo $CONFIG | jq -r '.gcp .redis .name')

MYSQL_IP=$(kubectl get sqlinstance $MYSQL_NAME -n config-connector -o jsonpath="{.status .privateIpAddress}")
POSTGRES_IP=$(kubectl get sqlinstance $POSTGRESQL_NAME -n config-connector -o jsonpath="{.status .privateIpAddress}")
REDIS_IP=$(kubectl get redisinstance $REDIS_NAME -n config-connector -o jsonpath="{.status .host}")

echo "{
    \"mysql_host\": \"$MYSQL_IP\", 
    \"postgresql_host\": \"$POSTGRES_IP\", 
    \"redis_host\": \"$REDIS_IP\" 
}"