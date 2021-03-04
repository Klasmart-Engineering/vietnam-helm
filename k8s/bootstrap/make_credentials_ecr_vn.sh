#!/bin/bash
set -e
set +x
source ../../scripts/bash/functions.sh

ENV=$1
env_validate "$ENV"

NS_KIDSLOOP=$(../../scripts/python/env_var.py $ENV $ENUM_NS_KIDSLOOP_VAR)
[ -z "$NS_KIDSLOOP" ] && echo "Missing variable,'$ENUM_NS_KIDSLOOP_VAR', in $ENV" && exit 1

current_pull_aws_access_key_id=$(kubectl get secret -n okc ecr-credentials-vn-pull -o jsonpath='{.data.aws_access_key_id}' | base64 --decode)
current_pull_secret_access_key=$(kubectl get secret -n okc ecr-credentials-vn-pull -o jsonpath='{.data.secret_access_key}' | base64 --decode)

current_push_aws_access_key_id=$(kubectl get secret -n okc ecr-credentials-vn-push -o jsonpath='{.data.aws_access_key_id}' | base64 --decode)
current_push_secret_access_key=$(kubectl get secret -n okc ecr-credentials-vn-push -o jsonpath='{.data.secret_access_key}' | base64 --decode)


echo -n "Vietnam: Pull Access Key ID [$current_pull_aws_access_key_id]: "
while read pull_access_key_id; do
  if [[ ! -z "$pull_access_key_id" ]]; then
    break
  elif [[ ! -z "$current_pull_aws_access_key_id" ]]; then
    access_key_id="$current_pull_aws_access_key_id"
    break
  fi
done

echo -n "Vietnam: Pull Secret Access Key [$(echo $current_pull_secret_access_key | cut -b -5)]: "
while read pull_secret_access_key; do
  if [[ ! -z "$pull_secret_access_key" ]]; then
    break
  elif [[ ! -z "$current_pull_secret_access_key" ]]; then
    secret_access_key="$current_pull_secret_access_key"
    break
  fi
done


echo -n "Vietnam: Push Access Key ID [$current_push_aws_access_key_id]: "
while read push_access_key_id; do
  if [[ ! -z "$push_access_key_id" ]]; then
    break
  elif [[ ! -z "$current_push_aws_access_key_id" ]]; then
    access_key_id="$current_push_aws_access_key_id"
    break
  fi
done

echo -n "Vietnam: Push Secret Access Key [$(echo $current_push_secret_access_key | cut -b -5)]: "
while read push_secret_access_key; do
  if [[ ! -z "$push_secret_access_key" ]]; then
    break
  elif [[ ! -z "$current_push_secret_access_key" ]]; then
    secret_access_key="$current_push_secret_access_key"
    break
  fi
done

create_namespace_if_not_exists "$NS_KIDSLOOP"
label_namespace_for_redis "$NS_KIDSLOOP"

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ecr-credentials-vn-pull
  namespace: $NS_KIDSLOOP
data:
  aws_access_key_id: $(echo -n $pull_access_key_id | base64)
  secret_access_key: $(echo -n $pull_secret_access_key | base64)
EOF


cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ecr-credentials-vn-push
  namespace: $NS_KIDSLOOP
data:
  aws_access_key_id: $(echo -n $push_access_key_id | base64)
  secret_access_key: $(echo -n $push_secret_access_key | base64)
EOF