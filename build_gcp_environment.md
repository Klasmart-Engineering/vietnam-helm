# Description

This documentation is a guide for building a GCP (Google Cloud Platform) environment for a Kidsloop project.

## Define bash env vars

```bash
export ENV_NAME=indonesia-rk-prod
export GCP_PROJECT=kl-idn-rumah-kisah-prod
```

## Create gcloud configuration on your local machine

```bash
# create gcloud config
gcloud config configurations create $ENV_NAME

# authenticate to google cloud SDK
gcloud auth login

# configure gcloud configuration settings
gcloud config set project $GCP_PROJECT
gcloud config set account stefan.andrei@opencredo.com
gcloud config set compute/region asia-southeast2
gcloud config set compute/zone asia-southeast2-b

# list GCP config
gcloud config configurations list

# activate GCP config
gcloud config configurations activate $ENV_NAME
```

## Create terraform Service Account

```bash
# create service account
gcloud iam service-accounts create terraform \
    --description="Used for building infrastructure with terraform" \
    --display-name="Terraform Service Account"

# grant service account and IAM GCP role
gcloud projects add-iam-policy-binding $GCP_PROJECT \
    --member="serviceAccount:terraform@${GCP_PROJECT}.iam.gserviceaccount.com" \
    --role="roles/owner"

# list service account
gcloud iam service-accounts list

# create service accoutn keys
gcloud iam service-accounts keys create ${GCP_PROJECT}-sa.json \
    --iam-account=terraform@${GCP_PROJECT}.iam.gserviceaccount.com

# move ${GCP_PROJECT}-sa.json file to a secure location on your machine, as it will be used by terraform GOOGLE_APPLICATION_CREDENTIALS env var
```

## Create terraform state bucket

Terraform state is stored in GCP bucket.

```bash
# create bucket
gsutil mb -b on -l asia-southeast2 gs://kidsloop-$ENV_NAME-tfstate
```

## Build VPC and GKE cluster with terraform

```bash
# have terraform service account key file as environment variable
export GOOGLE_APPLICATION_CREDENTIALS="~/${GCP_PROJECT}-sa.json"

# make sure you use terraform 0.14.11
cd terraform
bash init.sh $ENV_NAME
bash plan.sh $ENV_NAME
bash apply.sh $ENV_NAME
```

## Configure kubectl GKE access

```bash
# configure kubectl access to GKE cluster
gcloud container clusters get-credentials kidsloop --region asia-southeast2 --project $GCP_PROJECT

# list kubectl config
kubectl config get-contexts
```

## Enable GCP APIs

```bash
cd terraform/gcp
bash bootstrap.sh $ENV_NAME
```

## Setup python environment

```
# create python3 virtual env
python3 -m venv .env

# activate python env
source .env/bin/activate

# install pip packages
pip install -r requirements.txt
```

## Build GCP infra

```bash

cd k8s

# create k8s namespaces and secrets
bash bootstrap.sh indonesia-rk-prod

# create k8s secret with AWS credentials for h5p service
kubectl  -n okc create secret generic h5p-s3-secret \
  --from-literal=aws-access-key-id=<AWS_ACCESS_KEY_ID> \
  --from-literal=aws-secret-access-key=<AWS_SECRET_ACCESS_KEY>

# create jwt secret for auth-backend
kubectl -n okc create secret generic auth-jwt-credentials \
--from-file=private_key=/path/to/key \
--from-file=public_key=/path/to/key \
--from-literal=jwt_private_passphrase=<PASSPHRASE> \
--from-literal=jwt-algorithm=<ALGORITHM>

# create jwt secret for live-backend
kubectl -n okc create secret generic live-jwt-credentials \
--from-file=private_key=/path/to/key \
--from-file=public_key=/path/to/key \
--from-literal=private_passphrase=<PASSPHRASE> \
--from-literal=jwt-algorithm=<ALGORITHM>

# create xapi-dynamodb-secret
CREDS=$(echo '''[default]
aws_access_key_id = <AWS_ACCESS_KEY_ID>
aws_secret_access_key = <AWS_SECRET_ACCESS_KEY>
''')
kubectl -n okc create secret generic xapi-dynamodb-secret --from-literal=credentials=$CREDS

# create cms-backend-s3-secret
kubectl  -n okc create secret generic cms-backend-s3-secret \
  --from-literal=aws_access_key_id="<AWS_ACCESS_KEY_ID>" \
  --from-literal=secret_access_key="<AWS_SECRET_ACCESS_KEY>"

# create pdf-service-s3-secret
kubectl  -n okc create secret generic pdf-service-s3-secret \
  --from-literal=aws_access_key_id="<AWS_ACCESS_KEY_ID>" \
  --from-literal=secret_access_key="<AWS_SECRET_ACCESS_KEY>"

# create secret for elasticsearch
cd bootstrap
bash make_secret_elasticsearch.sh $ENV_NAME

# build gcp config connector resources (postgres db, mysql db, redis)
cd k8s
bash gke.sh $ENV_NAME

# install helm release for specific release
cd k8s
bash helm.sh $ENV_NAME diff --release=live-frontend
bash helm.sh $ENV_NAME apply --release=live-frontend
```
