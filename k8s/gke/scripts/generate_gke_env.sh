#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate $ENV

EXPECTED_GOOGLE_CLOUD_PROJECT=$(../scripts/python/env_var.py $ENV "terraform_project")
REGION=$(../scripts/python/env_var.py $ENV "terraform_region")
EXPECTED_CONTEXT="gke_${EXPECTED_GOOGLE_CLOUD_PROJECT}_${REGION}_kidsloop"
CONFIG=$(cat ../env/$ENV/config.json)
PROJECT=$(cat ../env/$ENV/tfvars.json | jq -r '.terraform_project')
MYSQL_NAME=$(echo $CONFIG | jq -r '.gcp .mysql .name')
MYSQL_USER=$(echo $CONFIG | jq -r '.gcp .mysql .user')
MYSQL_ASSESSMENT_USER=$(echo $CONFIG | jq -r '.gcp .mysql .assessment_user')
POSTGRESQL_NAME=$(echo $CONFIG | jq -r '.gcp .postgresql .name')
POSTGRESQL_USER=$(echo $CONFIG | jq -r '.gcp .postgresql .user')
POSTGRESQL_ASSESSMENT_DB=$(echo $CONFIG | jq -r '.gcp .postgresql .assessment_database')
POSTGRESQL_ATTENDANCE_DB=$(echo $CONFIG | jq -r '.gcp .postgresql .attendance_database')
POSTGRESQL_XAPI_DB=$(echo $CONFIG | jq -r '.gcp .postgresql .xapi_database')
POSTGRESQL_PDF_DB=$(echo $CONFIG | jq -r '.gcp .postgresql .pdf_database')
REDIS_NAME=$(echo $CONFIG | jq -r '.gcp .redis .name')

KIDSLOOP_NAMESPACE=$(echo $CONFIG | jq -r '.k8s_namespace_kidsloop')

MYSQL_IP=$(kubectl --context $EXPECTED_CONTEXT get sqlinstance $MYSQL_NAME -n config-connector -o jsonpath="{.status .privateIpAddress}")
POSTGRESQL_IP=$(kubectl --context $EXPECTED_CONTEXT get sqlinstance $POSTGRESQL_NAME -n config-connector -o jsonpath="{.status .privateIpAddress}")
REDIS_IP=$(kubectl --context $EXPECTED_CONTEXT get redisinstance $REDIS_NAME -n config-connector -o jsonpath="{.status .host}")

MYSQL_PROXY_IP=$(kubectl --context $EXPECTED_CONTEXT get service cloud-sql-proxy-mysql -n $KIDSLOOP_NAMESPACE -o jsonpath="{.spec .clusterIP}")

echo "{
    \"mysql_host\": \"$MYSQL_IP\",
    \"mysql_database\": \"$MYSQL_NAME\",
    \"mysql_username\": \"$MYSQL_USER\",
    \"mysql_assessment_username\": \"$MYSQL_ASSESSMENT_USER\",
    \"mysql_proxy_ip\": \"$MYSQL_PROXY_IP\",
    \"postgresql_host\": \"$POSTGRESQL_IP\", 
    \"postgresql_database\": \"$POSTGRESQL_NAME\",
    \"postgresql_assessment_database\": \"$POSTGRESQL_ASSESSMENT_DB\",
    \"postgresql_attendance_database\": \"$POSTGRESQL_ATTENDANCE_DB\",
    \"postgresql_xapi_database\": \"$POSTGRESQL_XAPI_DB\",
    \"postgresql_pdf_database\": \"$POSTGRESQL_PDF_DB\",
    \"postgresql_username\": \"$POSTGRESQL_USER\", 
    \"redis_host\": \"$REDIS_IP\"
}"