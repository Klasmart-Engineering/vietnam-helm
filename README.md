# Deployment

## Pre-requisites

The following tools need to be installed on the machine performing the deployment:

 * [helm](https://helm.sh)
 * [helmfile](https://github.com/roboll/helmfile)
 * [helm-diff](https://github.com/databus23/helm-diff)

## Installation

To view differences with deployed charts:

```
$ helmfile diff
```

To apply changes to cluster:

```
$ helmfile apply
```

