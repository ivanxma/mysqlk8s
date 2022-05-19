# Install MySQL Operator for Kubernetes
# This is the demo tutorial for the installation of enterprise-operator, enterprise-server, enterprise-router
#
## Steps
1. Download Docker Image from MOS
  - Download Docker Image for MySQL Server (mysql/enterprise-server:8.0)
  - Download Docker Image for MySQL Router (mysql/enterprise-router:8.0)
  - Download Enterprise-operator packages from MOS.  It includes 2 downloads - one is Docker Image and another download is about the yaml/helm deployments

2. Create Repository on OCI OKE registry
  - For my example, the repositories include 
    - ivanxma/enterprise-operator    (p34110324_800_Linux-x86-64)
    - ivanxma/enterprise-server     
    - ivanxma/enterprise-router

3. On machine with docker CLI, load the images including [ enterprise--operator, enterprise-server, enterprise-router ]
```
docker load -i ./mysql-enterprise-router-8.0.29.tar
docker load -i ./mysql-enterprise-server-8.0.29.tar
docker load -i ./mysql-enterprise-operator_8.0.29-2.0.4.tar
docker image ls
```

4. On OCI OKE Registry, create the repositories - including (enterprise-operator enterprise-server enterprise-router)
  - as an example, the following repositories are created as public repository
    - ivanxma/enterprise-operator 
    - ivanxma/enterprise-server 
    - ivanxma/enterprise-router
  - check the registry namespace in OCI tenancy.  
    - as such the <namespace>/ivanxma is the REPO environment variable

5 On machine with docker CLI, tag the images to OCI registry accordingly  (noted : the following repository might be removed without notice)
```
docker tag mysql/enterprise-server:8.0 iad.ocir.io/idazzjlcjqzj/ivanxma/enterprise-server:8.0.29
docker tag mysql/enterprise-router:8.0 iad.ocir.io/idazzjlcjqzj/ivanxma/enterprise-router:8.0.29
docker tag mysql/enterprise-operator:8.0.29-2.0.4 iad.ocir.io/idazzjlcjqzj/ivanxma/enterprise-operator:8.0.29-2.0.4
```

---
At this point, the registry is ready for installation.

The enterprise operator downnload package (p34110382_800_Generic) has the helm folder with the helm charts for 
  - mysql-operator-2.0.4.tgz
  - mysql-innodbcluster-2.0.4.tgz


6. Open a shell terminal with helm and kubectl configured, set up the REPO and REGISTRY variables.   For our example with public repositories setup :
```
export REPO=idazzjlcjqzj/ivanxma
export REGISTRY=iad.ocir.io
```

7. Install enterprise-operator  (package : p34110382_800_Generic)
```
cd p34110382_800_Generic/helm
helm install mysql-operator ./mysql-operator-2.0.4.tgz -n mysql-operator --create-namespace --set image.registry=$REGISTRY --set image.repository=$REPO --set envs.imagesDefaultRegistry="$REGISTRY" --set envs.imagesDefaultRepository="$REPO" --set image.pullPolicy='Always'

kubectl get pod -n mysql-operator --watch
```

8. Install mysql-innodbcluster (package: p34110382_800_Generic)
- Get parameters for Innodb Cluster settings   (make sure the current folder is on the helm folder)

```
cd p34110382_800_Generic/helm
helm show values  ./mysql-operator-2.0.4.tgz > ic.values
```

- Append the following sections to ic.values (make changes to the username/password
```
credentials:
  root:
    user: root
    password: sakila
    host: "%"

tls:
  useSelfSigned: true
```

-  Install Innodb cluster with name as 'mycluster' using the helm chart + modified ic.values parameters
```
helm install myclluster ./mysql-innodbcluster-2.0.4.tgz -n myic-demo --create-namespace --set image.registry=$REGISTRY --set image.repository=$REPO --set envs.imagesDefaultRegistry="$REGISTRY" --set envs.imagesDefaultRepository="$REPO" --set image.pullPolicy='Always' -f ic.values
```

- wait util all deployed and running
```
kubectl get pod -n myic-demo --watch
```

9. Test mysql login

```
kubectl port-forward svc/mycluster -n myic-demo 3306 &

mysql -uroot -h127.0.0.1 -P3306 -p<the password>
```

# Done - you have finished deployment using enterprise package
