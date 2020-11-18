# Deployment

## Pre-requisites

The following tools need to be installed on the machine performing the deployment:

 * [helm](https://helm.sh)
 * [helmfile](https://github.com/roboll/helmfile)
 * [helm-diff](https://github.com/databus23/helm-diff)
 * [aws-cli-v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
 * [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

It is assumed that you have the appropriate AWS (`~/.aws/credentials`) and Kubernetes (`~/.kube/config`)
configuration setup and your environment variables are setup such that the correct AWS account and correct
Kubernetes cluster are targetted.

## Installation

### Bootstrap

To bootstrap the application installation the following steps need to be performed. Once
the cluster is bootstrapped all management will be done via Helm.


#### Create namespace
```bash
$ kubectl create ns okc

namespace/foo created

$ kubectl label ns okc redis-namespace="true"

namespace/okc labeled
```

#### Add AWS credentials

Create a new AWS programmatic user with an access key. The AWS user needs to be able to pull Docker images from ECR.
Run the following script and supply the access key ID and the key:

```bash
$ ./bootstrap/make_credentials.sh

Access Key ID: foo
Secret Access Key: bar
secret/aws-credentials configured
```

#### Add bootstrap ECR token

Add bootstrap ECR token. Once the Helm charts are deployed this will be refresh automatically:

```bash
$ ./bootstrap/make_secret.sh

+ REGION=ap-northeast-2
+ export AWS_DEFAULT_REGION=ap-northeast-2
+ AWS_DEFAULT_REGION=ap-northeast-2
+ echo 'Region: ap-northeast-2'
Region: ap-northeast-2
+ SECRET_NAME=ecr-registry
+ NAMESPACE=okc
+ DRY_RUN=no
++ aws ecr get-login-password
...
...
...
```

#### Update CoreDNS configuration

CoreDNS is deployed as part of the Kubernetes managed infrastructure and not currently managed via Helm. To support directly addressable pods (needed for the SFUs) we need to modify CoreDNS's configmap:

```bash
$ kubectl apply -f bootstrap/coredns-configmap.yaml

configmap/coredns configured
```

### Install Application

To view differences with deployed charts:

```bash
$ helmfile diff
```

To apply changes to cluster:

```bash
$ helmfile apply
```

