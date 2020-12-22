#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

SVC=$2

MYSQL=$(../scripts/python/env_var.py $ENV "k8s_mysql")
[ -z "$MYSQL" ] && echo "Missing variable,'k8s_mysql', in $ENV" && exit 1
POSTGRESQL=$(../scripts/python/env_var.py $ENV "k8s_postgresql")
[ -z "$POSTGRESQL" ] && echo "Missing variable,'k8s_postgresql', in $ENV" && exit 1
PROMETHEUS=$(../scripts/python/env_var.py $ENV "k8s_prometheus")
[ -z "$PROMETHEUS" ] && echo "Missing variable,'k8s_prometheus', in $ENV" && exit 1
FLUENTBIT=$(../scripts/python/env_var.py $ENV "k8s_fluentbit")
[ -z "$FLUENTBIT" ] && echo "Missing variable,'k8s_fluentbit', in $ENV" && exit 1


pushd bootstrap


TXT="MySQL passwords as K8s Secrets"
if [[ "$MYSQL" = "bitnami" && ((-z "$SVC") || "$SVC" = "mysql") ]]
then
    echo_heading "Generating $TXT"
    ./make_secret_mysql.sh $ENV
else
    echo_heading "Skipping $TXT"
fi


TXT="PostgreSQL passwords as K8s Secrets"
if [[ "$POSTGRESQL" = "bitnami" && ((-z "$SVC") || "$SVC" = "postgresql") ]]
then
    echo_heading "Generating $TXT"
    ./make_secret_postgresql.sh $ENV
else
    echo_heading "Skipping $TXT"
fi


TXT="Prometheus CRDs"
if [[ "$PROMETHEUS" = "bitnami" && ((-z "$SVC") || "$SVC" = "prometheus") ]]
then
    echo_heading "Installing $TXT"
    ./install_prometheus_crds.sh
else
    echo_heading "Skipping $TXT"
fi


TXT="initial ECR token secret for pulling KidsLoop container images"
if [[ (-z "$SVC") || ("$SVC" = "ecr") ]]
then
    echo_heading "Installing $TXT"
    ./make_secret_ecr.sh
else
    echo_heading "Skipping $TXT"
fi


TXT="AWS credentials Secret for cronjob to refresh ECR token"
if [[ (-z "$SVC") || ("$SVC" = "ecr") ]]
then
    echo_heading "Generating $TXT"
    ./make_credentials_ecr.sh $ENV
else
    echo_heading "Skipping $TXT"
fi


TXT="AWS credentials Secret for Fluentbit log shipping"
if [[ "$FLUENTBIT" = "fluent" && ((-z "$SVC") || "$SVC" = "fluentbit") ]]
then
    echo_heading "Generating $TXT"
    ./make_credentials_fluentbit.sh $ENV
else
    echo_heading "Skipping $TXT"
fi


popd
