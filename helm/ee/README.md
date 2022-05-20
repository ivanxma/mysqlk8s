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
    - as such the &lt;namespace&gt;/ivanxma is the REPO environment variable

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
helm install mycluster ./mysql-innodbcluster-2.0.4.tgz -n myic-demo --create-namespace --set image.registry=$REGISTRY --set image.repository=$REPO --set envs.imagesDefaultRegistry="$REGISTRY" --set envs.imagesDefaultRepository="$REPO"  -f ic.values
```

- wait util all pods and innodb cluster are deployed, and they are online & running
```
kubectl get pod -n myic-demo 
kubectl get ic -n myic-demo 
```

9. Test mysql login
- Using port-forward to get local 3306 port to connect to the service/mycluster (ROUTER service)
- and Connecting to router service using mysql client.  The user/password is given in the previous appended ic.values.

```
kubectl port-forward svc/mycluster -n myic-demo 3306 &
mysql -uroot -h127.0.0.1 -P3306 -p<the password>
```

---
## Additional operations for Innodb Cluster

1. Running mysqlsh within the container "sidecar"
```
kubectl exec -it mycluster-0 -n myic-demo -c sidecar -- mysqlsh root:sakila@127.0.0.1:3306 -e " print(dba.getCluster().status())"
```


2. Running SQL mode with MySQL Shell connecting to the 3 nodes using hostname
```
kubectl exec -it mycluster-0 -n myic-demo - c sidecar -- mysqlsh --sql -uroot -psakila -hmycluster-0.mycluster-instances.myic-demo.svc.cluster.local -e "select @@hostname, @@port;"
kubectl exec -it mycluster-0 -n myic-demo - c sidecar -- mysqlsh --sql -uroot -psakila -hmycluster-1.mycluster-instances.myic-demo.svc.cluster.local -e "select @@hostname, @@port;"
kubectl exec -it mycluster-0 -n myic-demo - c sidecar -- mysqlsh --sql -uroot -psakila -hmycluster-2.mycluster-instances.myic-demo.svc.cluster.local -e "select @@hostname, @@port;"
```

3. Creating demo data with the Innodb Cluster
```
kubectl exec -it mycluster-0 -n myic-demo - c sidecar -- mysqlsh --sql -uroot -psakila -hmycluster-0.mycluster-instances.myic-demo.svc.cluster.local -e "create database demo;create table demo.mytable (f1 int not null primary key, f2 varchar(20));insert into demo.mytable values (1, 'aaa');"
```

4. Rollout restart the statefulset with mycluster
- The pod(s) will be terminated and re-initialized one by one.   

```
kubectl get statefulset -n myic-demo
kubectl rollout restart statefulset mycluster -n myic-demo
kubectl get pod -n myic-demo --watch
```
- Press **CTRL-C** to cancel the 'watch'
- Reselect the data and after all nodes restarted (recreated), data is still there
```
kubectl exec -it mycluster-0 -n myic-demo - c sidecar -- mysqlsh --sql -uroot -psakila -hmycluster-0.mycluster-instances.myic-demo.svc.cluster.local -e "select @@hostname,@@port,a.* from demo.mytable;"
```

5. Check IC status
```
kubectl get ic -n myic-demo
```

6. Showing the logs for pod (on each node)
```
kubectl logs mycluster-2 -c mysql -n myic-demo
kubectl logs mycluster-1 -c mysql -n myic-demo
kubectl logs mycluster-0 -c mysql -n myic-demo
```


# Done - you have finished deployment using enterprise package
