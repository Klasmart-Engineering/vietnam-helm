#!/bin/bash
set -e
source ../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

pushd helm
helmfile -e $ENV apply
popd

