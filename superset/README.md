# Installation of superset
## The following steps trying to use helm based on the URL :
### https://superset.apache.org/docs/installation/running-on-kubernetes/

## OCI cli installation
### https://docs.oracle.com/en/learn/oke_with_service_broker/prereq/prereq.html#introduction

## kubectl installation and configuration
### Install kubectl
###   https://kubernetes.io/docs/tasks/tools/
### Config access to OKE
###   Login to OCI console and select the OKE cluster and open the Access Cluster.
###   create folder $HOME/.kube
###   Copy the command using oci cli to create kube configuration file


## helm installation
### https://helm.sh/docs/intro/install/

## Installation superset repo
```
helm repo add superset https://apache.github.io/superset
```

## Listing repository
```
helm search repo superset
```

## Configure your setting overrides
### Listing the setting to custom-values.yaml
### if needed, change the values
```
helm show values superset/superset > custom-values.yaml
```

## Deploy helm
```
helm upgrade --install --values custom-values.yaml superset superset/superset
```

## Deploy LoadBalancer Service

- lb.yaml :  apply the following yaml [kubectl apply -f lb.yaml ]
```
apiVersion: v1
kind: Service
metadata:
  name: my-superset-svc
  labels:
    app: superset-lb
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8088
  selector:
    app: superset
```
