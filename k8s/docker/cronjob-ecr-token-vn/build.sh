#!/bin/bash
set -x
set -e

export AWS_DEFAULT_REGION=ap-southeast-1
export AWS_ACCESS_KEY_ID=$(kubectl get secret -n okc ecr-credentials-vn-push -o jsonpath='{.data.aws_access_key_id}' | base64 --decode)
export AWS_SECRET_ACCESS_KEY=$(kubectl get secret -n okc ecr-credentials-vn-push -o jsonpath='{.data.secret_access_key}' | base64 --decode)

echo Build docker image
cp ../../bootstrap/make_secret_ecr_vn.sh .
docker build -t 242787759841.dkr.ecr.ap-southeast-1.amazonaws.com/kidsloop-ecr-token:latest .
rm -f make_secret_ecr_vn.sh

echo Docker login and push
aws ecr get-login-password | docker login --username AWS --password-stdin 242787759841.dkr.ecr.ap-southeast-1.amazonaws.com
docker push 242787759841.dkr.ecr.ap-southeast-1.amazonaws.com/kidsloop-ecr-token:latest
