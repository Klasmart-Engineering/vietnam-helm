#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate $ENV

CONFIG=$(cat ../env/$ENV/config.json)
PROJECT=$(cat ../env/$ENV/tfvars.json | jq -r '.terraform_project')
MYSQL_NAME=$(echo $CONFIG | jq -r '.gcp .mysql .name')
MYSQL_USER=$(echo $CONFIG | jq -r '.gcp .mysql .user')
POSTGRESQL_NAME=$(echo $CONFIG | jq -r '.gcp .postgresql .name')
POSTGRESQL_USER=$(echo $CONFIG | jq -r '.gcp .postgresql .user')
REDIS_NAME=$(echo $CONFIG | jq -r '.gcp .redis .name')

KIDSLOOP_NAMESPACE=$(echo $CONFIG | jq -r '.k8s_namespace_kidsloop')

MYSQL_IP=$(kubectl get sqlinstance $MYSQL_NAME -n config-connector -o jsonpath="{.status .privateIpAddress}")
POSTGRESQL_IP=$(kubectl get sqlinstance $POSTGRESQL_NAME -n config-connector -o jsonpath="{.status .privateIpAddress}")
REDIS_IP=$(kubectl get redisinstance $REDIS_NAME -n config-connector -o jsonpath="{.status .host}")

MYSQL_PROXY_IP=$(kubectl get service cloud-sql-proxy-mysql -n $KIDSLOOP_NAMESPACE -o jsonpath="{.spec .clusterIP}")

echo "{
    \"mysql_host\": \"$MYSQL_IP\",
    \"mysql_database\": \"$MYSQL_NAME\",
    \"mysql_username\": \"$MYSQL_USER\",
    \"mysql_proxy_ip\": \"$MYSQL_PROXY_IP\",
    \"postgresql_host\": \"$POSTGRESQL_IP\", 
    \"postgresql_database\": \"$POSTGRESQL_NAME\",
    \"postgresql_username\": \"$POSTGRESQL_USER\", 
    \"redis_host\": \"$REDIS_IP\"
}"