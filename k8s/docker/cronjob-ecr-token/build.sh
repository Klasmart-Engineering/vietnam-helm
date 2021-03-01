#!/bin/bash
set +x
set -e

export AWS_DEFAULT_REGION=ap-northeast-2
export AWS_ACCESS_KEY_ID=$(kubectl get secret -n okc ecr-credentials-push -o jsonpath='{.data.aws_access_key_id}' | base64 --decode)
export AWS_SECRET_ACCESS_KEY=$(kubectl get secret -n okc ecr-credentials-push -o jsonpath='{.data.secret_access_key}' | base64 --decode)

echo Build docker image
cp ../../bootstrap/make_secret_ecr.sh .
docker build -t 494634321140.dkr.ecr.ap-northeast-2.amazonaws.com/vietnam-ecr-token:latest . 
rm -f make_secret_ecr.sh

echo Docker login and push
aws ecr get-login-password | docker login --username AWS --password-stdin 494634321140.dkr.ecr.ap-northeast-2.amazonaws.com
docker push 494634321140.dkr.ecr.ap-northeast-2.amazonaws.com/vietnam-ecr-token:latest
