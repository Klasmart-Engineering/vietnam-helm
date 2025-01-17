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
CLOUD_PROVIDER=$(../scripts/python/env_var.py $ENV provider)
[ -z "$CLOUD_PROVIDER" ] && echo "Missing variable,'provider', in $ENV" && exit 1

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

TXT="Store AWS credentials for ECR as a Secret (for refresh ECR token cronjob)"
if [[ (-z "$SVC") || ("$SVC" = "ecr-credentials") ]]
then
    echo_heading "Generating $TXT"
    ./make_credentials_ecr_infra.sh $ENV
else
    echo_heading "Skipping $TXT"
fi


TXT="Initial token secret for pulling ECR container images (refreshed by cron job)"
if [[ (-z "$SVC") || ("$SVC" = "ecr-registry") ]]
then
    echo_heading "Installing $TXT"
    ./make_secret_ecr_infra.sh $ENV
else
    echo_heading "Skipping $TXT"
fi

TXT="AWS credentials Secret for Fluentbit log shipping"
if [[ "$FLUENTBIT" = True && ((-z "$SVC") || "$SVC" = "fluentbit") ]]
then
    echo_heading "Generating $TXT"
    ./make_credentials_fluentbit.sh $ENV
else
    echo_heading "Skipping $TXT"
fi

popd
