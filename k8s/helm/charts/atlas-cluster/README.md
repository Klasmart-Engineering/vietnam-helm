
# Chart documentation

https://github.com/mongodb/helm-charts/tree/main/charts/atlas-cluster
https://docs.atlas.mongodb.com/

# Prerequisites for installing helm chart

The atlas-cluster chart requires two secrets to be available in the k8s cluster:
- db user secret
- atlas cloud API keys

```
# create db user secret via k8s/bootstrap.sh script when creating secrets for all applications
# or manually
cd k8s/bootstrap
bash make_secret_h5p_mongodb_atlas.sh indonesia-production

# manually create secret for atlas cloud API keys
kubectl  -n okc create secret generic mongodb-atlas-cluster-secret \
  --from-literal=orgId="" \
  --from-literal=privateApiKey="" \
  --from-literal=publicApiKey=""
```
