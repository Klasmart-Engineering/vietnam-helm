# Kidsloop cluster level dependencies chart

Deploy:

```bash
helmfile apply --skip-diff-on-install
```

## To fix...

CRDs didn't install correctly the first time around. Applied manually with this:

Copy them into templates?

```
kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/charts/aws-calico/crds/crds.yaml
```
