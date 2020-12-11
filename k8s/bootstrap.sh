#!/bin/bash
set -e
source _functions.sh

pushd bootstrap

echo_heading "Generating MySQL passwords as K8s Secrets"
./make_secret_mysql.sh

echo_heading "Generating PostgreSQL passwords as K8s Secrets"
./make_secret_mysql.sh

echo_heading "Installing Prometheus CRDs\n"
./install_prometheus_crds.sh

pushd ../docker

echo_heading "Installing initial ECR token secret for pulling KidsLoop container images"
../docker/vietnam-ecr-token/make_secret.sh

popd

echo_heading "Generating AWS credentials Secret for cronjob to refresh ECR token"
./make_credentials.sh

echo_heading "Generating AWS credentials Secret for Fluentbit log shipping"
./make_credentials_fluentbit.sh

popd
