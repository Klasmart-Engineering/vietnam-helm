#!/bin/bash
set -x
set -e

# Create temp directory
DIR=$(mktemp -d)
pushd $DIR

# Clone 1 level of Bitnami charts
git clone --depth 1 https://github.com/bitnami/charts

# Enter CRDs directory
pushd charts/bitnami/kube-prometheus/crds

# Apply CRDs
kubectl apply -f .

# Return to start
popd && popd

# Delete temp directory
rm -rf $DIR
