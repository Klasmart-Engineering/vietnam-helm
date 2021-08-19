# Description

This documentation is a guide for deploying a helm release.

```bash
# Define bash env vars
export ENV_NAME=indonesia-rk-prod
export GCP_PROJECT=kl-idn-rumah-kisah-prod

# activate GCP config
gcloud config configurations activate $ENV_NAME

# have terraform service account key file as environment variable
export GOOGLE_APPLICATION_CREDENTIALS="~/${GCP_PROJECT}-sa.json"

# initiate terraform. Make sure you use terraform 0.14.11
cd terraform
bash init.sh $ENV_NAME

# configure kubectl access to GKE cluster
gcloud container clusters get-credentials kidsloop --region asia-southeast2 --project $GCP_PROJECT

# verify kubectl config
kubectl config get-contexts

# create python3 virtual env
python3 -m venv .env
source .env/bin/activate
pip install -r requirements.txt

# build gcp config connector resources (postgres db, mysql db, redis)
cd ../k8s
bash gke.sh $ENV_NAME

# install helm release for specific release
bash helm.sh $ENV_NAME diff --release=live-frontend
bash helm.sh $ENV_NAME apply --release=live-frontend
```
