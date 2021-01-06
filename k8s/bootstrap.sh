#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

SVC=$2

PROMETHEUS=$(../scripts/python/env_is_enabled.py $ENV helm_prometheus)
[ -z "$PROMETHEUS" ] && echo "Missing variable,'helm_prometheus', in $ENV" && exit 1
FLUENTBIT=$(../scripts/python/env_is_enabled.py $ENV helm_fluentbit)
[ -z "$FLUENTBIT" ] && echo "Missing variable,'helm_fluentbit', in $ENV" && exit 1


pushd bootstrap

# Used for both Bitnami helm deployment and config connector SQLUser
TXT="MySQL passwords as K8s Secrets"
if [[ (-z "$SVC") || ("$SVC" = "mysql") ]]
then
    echo_heading "Generating $TXT"
    ./make_secret_mysql.sh $ENV
else
    echo_heading "Skipping $TXT"
fi

# Used for both Bitnami helm deployment and config connector SQLUser
TXT="PostgreSQL passwords as K8s Secrets"
if [[ (-z "$SVC") || ("$SVC" = "postgresql") ]]
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
    ./make_secret_ecr.sh $ENV
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
