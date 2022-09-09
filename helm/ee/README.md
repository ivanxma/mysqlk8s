# Install MySQL Operator for Kubernetes [8.0.30-2.0.6]
# This is the demo tutorial for the installation of enterprise-operator, enterprise-server, enterprise-router
#
## Steps
1. Download Docker Image from MOS
  - Login to https://support.oracle.com and Download
    - MySQL Commercial Server 8.0.30 Docker Image TAR for Generic Linux x86 (64bit) (Patchset)
      - This includes the MySQL Server and MySQL Router Docker Images
      - Download Docker Image for MySQL Server (mysql/enterprise-server:8.0)
      - Download Docker Image for MySQL Router (mysql/enterprise-router:8.0)
    - Download Enterprise-operator packages from MOS.  
      - It includes 2 downloads - one is Docker Image and another download is about the yaml/helm deployments
    - For 8.0.30-2.0.6 :
      - Patch ID : 34421881	MySQL Commercial Server 8.0.30 Docker Image TAR for Generic Linux x86 (64bit) (Patchset)
      - Patch ID : 34563969	MySQL Operator 8.0.30-2.0.6 Docker Image TAR for Generic Linux x86 (64bit) (Patchset)
      - Patch ID : 34563968	MySQL Operator 8.0.30-2.0.6 YAML+HELM for Generic Platform (Patchset)


2. Create Repository on OCI OKE registry (just put a name as [prefix])
  - For my example, the repositories include 
    - [prefix]/enterprise-operator    (p34110324_800_Linux-x86-64)
    - [prefix]/enterprise-server     
    - [prefix]/enterprise-router

3. On machine with docker CLI, load the images including [ enterprise--operator, enterprise-server, enterprise-router ]
  - unzip the Downloaded MySQL Server and MySQL Router Packages [34421881] and using docker CLI to load the images
```
docker load -i ./mysql-enterprise-router-8.0.30.tar
docker load -i ./mysql-enterprise-server-8.0.30.tar
```

  - unzip the Downloaded MySQL Operator Package [34563969] and using docker CLI to load the images
```
docker load -i ./mysql-enterprise-operator-8.0.30-2.0.6-docker.tar.g
```

  - to show image loaded and tag to the docker
```
docker image ls
```

4. On OCI OKE Registry, create the repositories - including (enterprise-operator enterprise-server enterprise-router)
  - as an example, 
    - [prefix]/enterprise-operator 
    - [prefix]/enterprise-server 
    - [prefix]/enterprise-router
  - check the registry namespace in OCI tenancy.  
    - as such the &lt;namespace&gt;/[prefix] is the REPO environment variable

5 On machine with docker CLI, tag the images to OCI registry accordingly  (noted : the following repository might be removed without notice)
```
docker tag mysql/enterprise-server:8.0 [region].ocir.io/[Namespace]/[prefix]/enterprise-server:8.0.30
docker tag mysql/enterprise-router:8.0 [region].ocir.io/[Namespace]/[prefix]/enterprise-router:8.0.30
docker tag mysql/enterprise-operator:8.0.30-2.0.6 [region].ocir.io/[Namespace]/[prefix]/enterprise-operator:8.0.30-2.0.6
```
---
On OCI Console, note down the following regarding registry namespace and authentication token.  
- How can you locate the Registry Namespace?
  - Choose Contaier Registry from Hamburgen menu
  - Select the create Registry's Repositry and Locate the Namespace in the details Screen.
- How can you create/locate the user name and authentication token for Registry login?
  - At the right upper corner, locate the User Profile Icon and SELECT the user profile
    - Noted down the Profile name as something similar to
      - oracleidentitycloudservice/[user]@[company]
    - On Resource menu, choose **Auth Tokens** 
      - Click **Generate Token** and fill in the Description to generate the token
      - Note down the Token  [Token]

On machine with docker CLI, login REPO and provide the Token info as password
```
docker login [region].ocir.io 
```
-  (e.g. docker login iad.ocir.io)

And using the docker CLI to push the image to Registry
```
docker push [region].ocir.io/[Namespace]/[prefix]/enterprise-server:8.0.30
docker push [region].ocir.io/[Namespace]/[prefix]/enterprise-router:8.0.30
docker push [region].ocir.io/[Namespace]/[prefix]/enterprise-operator:8.0.30-2.0.6
```


---
At this point, the registry is ready for installation; You have the following information :
  - User Profile Identity (e.g. oracleidentitycloudservice/[user]@[company]
  - Registry Namespace 
  - Auth Token
  - The region where the Registry Repositry is created
    - e.g. for US-ASHBURN, the [region] is iad.  For complete reference, you can refer to https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm
      - The docker server URL for Repository is [region].ocir.io

And 3 Registry Repositories are created (with uploaded 8.0.30 images)
  - [prefix]/enterprise-server
  - [prefix]/enterprise-router
  - [prefix]/enterprise-operator


The enterprise operator downnload package (p34563968_800_Generic) has the helm folder with the helm charts for 
  - mysql-operator-2.0.6.tgz
  - mysql-innodbcluster-2.0.6.tgz

---
6. Preparation of the environment

- Setup Environment Variables
  - Open a shell terminal with helm and kubectl configured, set up the variables including - REPO, REGISTRY, TOKEN and USER
  ```
  export REPO=[Namespace]/[prefix]
  export REGISTRY=[region].ocir.io
  export TOKEN=[token]
  export DOCKERUSER=[Namespace]/oracleidentitycloudservice/[user]@[company]
  export BUCKETNAME=mybucket-operator
  ```

  - Using a demo namespace (e.g. myic-demo)
  ```
  export DEMOSPACE=myic-demo
  ```

  - Create a namespace 'mysql-operator'
  ```
  kubectl create ns mysql-operator
  ```

- Create Docker Registry Secret  within the namespace 'mysql-operator'
```
kubectl create secret docker-registry 'mysql-registry-secret' -n mysql-operator --docker-server=$REGISTRY --docker-username=$DOCKERUSER --docker-password=$TOKEN
```

7. Install enterprise-operator  (package : p34563968_800_Generic)
- Switch to the helm folder
```
cd p34563968_800_Generic/helm
```

- Install mysql-operator
```
helm install mysql-operator ./mysql-operator-2.0.6.tgz -n mysql-operator --set image.registry=$REGISTRY --set image.repository=$REPO --set envs.imagesDefaultRegistry="$REGISTRY" --set envs.imagesDefaultRepository="$REPO" --set image.pullSecrets.secretName=mysql-registry-secret --set image.pullSecrets.enabled=true --set image.name="enterprise-operator"
```

- Check the status 
```
kubectl get pod -n mysql-operator --watch
```
Press **CTRL-C** to stop watching 

8. Install mysql-innodbcluster (package: p34110382_800_Generic)
- Get parameters for Innodb Cluster settings   (make sure the current folder is on the helm folder)

  - switching to folder on helm from the downloaded zip
  ```
  cd p34110382_800_Generic/helm
  ```

  - Extract the configuration values from the mysql-opreator chart
  ```
  helm show values  ./mysql-operator-2.0.6.tgz > ic.values
  ```

  - Append the following sections to ic.values (make changes to include the username/password )
  ```
  credentials:
    root:
      user: root
      password: sakila
      host: "%"
  
  tls:
    useSelfSigned: true
  ```

  - Append the following sections to ic.values (make changes to include the datadir PVC storage)
  ```
  datadirVolumeClaimTemplate:
    accessModes:  "ReadWriteOnce"
    resources:
      requests:
        storage: 100Gi
  ```
  
  - Append the following sections to ic.values (make changes [BUCKETNAME] to include the backup schedule)
  ```
  backupSchedules:
  - name: myschdule
    schedule: "*/30 * * * *"
    deleteBackupData: false
    enabled: true
  
    backupProfile:
      dumpInstance:
        storage:
          ociObjectStorage:
            prefix: mycluster-backup
            bucketName: [BUCKETNAME]
            credentials: backup-apikey
  ```

  - Append the following sections to ic.values (make changes [REGISTRY], [Namespace], [Prefix] to include the backup schedule)
  ```
  image:
    pullPolicy: IfNotPresent
    pullSecrets:
      enabled: true
      secretName: mysql-registry-secret
  
  envs:
      imagesPullPolicy: IfNotPresent
      imagesDefaultRegistry: [REGISTRY]
      imagesDefaultRepository: [Namespace]/[Prefix]
  ```


  Backup Profile [dumpInstance] is created to dump data on to Object Storage on OCI.
  The ic.values contains the value about the credential to login to OCI and the bucketName - mybucket-operator

  - Login to OCI consolde and Choose **Object Storage** from Storage Menu.
  - Create bucket "mybucket-operator" - under the compartment defined by the credentials. 

- On Namespace $DEMOSPACE, to create registry secret and deploy InnoDB Cluster Pods
  - Create namespace $DEMOSPACE
  ```
  kubectl create ns $DEMOSPACE
  ```

  - Create Docker Registry Secret  within the namespace '$DEMOSPACE'
  ```
  kubectl create secret docker-registry 'mysql-registry-secret' -n $DEMOSPACE --docker-server=$REGISTRY --docker-username=$DOCKERUSER --docker-password=$TOKEN
  ```

  - Create api credential for Object Storage access [ lookup your $HOME/.oci/config and update the corresponding info accordingly ]
  ```
  cat << EOF|kubectl apply -n $DEMOSPACE -f -
  apiVersion: v1
  kind: Secret
  type: Opaque
  metadata:
    name: backup-apikey
  stringData:
    fingerprint: 68:....
    passphrase : ""
    privatekey: |
      -----BEGIN RSA PRIVATE KEY-----
      [ get your private key ]
      -----END RSA PRIVATE KEY-----
    region: us-ashburn-1
    tenancy: ocid1.tenancy.oc1..
    user: ocid1.user.oc1...
  EOF
  ```

  -  Install Innodb cluster with name as 'mycluster' using the helm chart + modified ic.values parameters
  ```
  helm install mycluster ./mysql-innodbcluster-2.0.6.tgz -n $DEMOSPACE -f ic.values 
  ```

  - wait util all pods and innodb cluster are deployed. Check status with the deployed pods/deployment and cronjob.
  ```
  kubectl get pod -n $DEMOSPACE 
  kubectl get ic -n $DEMOSPACE 
  kubectl get cronjob -n $DEMOSPACE
  kubectl describe cronjob/mycluster-myschdule-cb -n $DEMOSPACE
  ```

9. Test mysql login
- Using port-forward to get local 3306 port to connect to the service/mycluster (ROUTER service)
- and Connecting to router service using mysql client.  The user/password is given in the previous appended ic.values.

```
kubectl port-forward svc/mycluster -n $DEMOSPACE 3306 &
mysql -uroot -h127.0.0.1 -P3306 -p[the password]
```

---
## Additional operations for Innodb Cluster

1. Running mysqlsh within the container "sidecar"
```
kubectl exec -it mycluster-0 -n $DEMOSPACE -c sidecar -- mysqlsh root:sakila@127.0.0.1:3306 -e " print(dba.getCluster().status())"
```


2. Running SQL mode with MySQL Shell connecting to the 3 nodes using hostname
```
kubectl exec -it mycluster-0 -n $DEMOSPACE -c sidecar -- mysqlsh --sql -uroot -psakila -hmycluster-0.mycluster-instances.$DEMOSPACE.svc.cluster.local -e "select @@hostname, @@port;"
kubectl exec -it mycluster-0 -n $DEMOSPACE -c sidecar -- mysqlsh --sql -uroot -psakila -hmycluster-1.mycluster-instances.$DEMOSPACE.svc.cluster.local -e "select @@hostname, @@port;"
kubectl exec -it mycluster-0 -n $DEMOSPACE -c sidecar -- mysqlsh --sql -uroot -psakila -hmycluster-2.mycluster-instances.$DEMOSPACE.svc.cluster.local -e "select @@hostname, @@port;"
```

3. Creating demo data with the Innodb Cluster
```
kubectl exec -it mycluster-0 -n $DEMOSPACE -c sidecar -- mysqlsh --sql -uroot -psakila -hmycluster-0.mycluster-instances.$DEMOSPACE.svc.cluster.local -e "create database demo;create table demo.mytable (f1 int not null primary key, f2 varchar(20));insert into demo.mytable values (1, 'aaa');"
```

4. Rollout restart the statefulset with mycluster
- The pod(s) will be terminated and re-initialized one by one.   

```
kubectl get statefulset -n $DEMOSPACE
kubectl rollout restart statefulset mycluster -n $DEMOSPACE
kubectl get pod -n $DEMOSPACE --watch
```
Press **CTRL-C** to cancel the 'watch'

- Reselect the data and after all nodes restarted (recreated), data is still there
```
kubectl exec -it mycluster-0 -n $DEMOSPACE -c sidecar -- mysqlsh --sql -uroot -psakila -hmycluster-0.mycluster-instances.$DEMOSPACE.svc.cluster.local -e "select @@hostname,@@port,a.* from demo.mytable;"
```

5. Check innodb cluster status
```
kubectl get ic -n $DEMOSPACE
```

6. Showing the logs 
```
kubectl logs mycluster-2 -c mysql -n $DEMOSPACE
kubectl logs mycluster-1 -c mysql -n $DEMOSPACE
kubectl logs mycluster-0 -c mysql -n $DEMOSPACE
kubectl logs deployment/mysql-operator -n mysql-operator
```

7. Check Time-Zone
```
kubectl exec -it mycluster-0 -n $DEMOSPACE -c sidecar -- mysqlsh root:sakila@127.0.0.1:3306 --sql -e " select @@hostname, @@time_zone;"
kubectl exec -it mycluster-1 -n $DEMOSPACE -c sidecar -- mysqlsh root:sakila@127.0.0.1:3306 --sql -e " select @@hostname, @@time_zone;"
kubectl exec -it mycluster-2 -n $DEMOSPACE -c sidecar -- mysqlsh root:sakila@127.0.0.1:3306 --sql -e " select @@hostname, @@time_zone;"
```
and Change the time zone to +08:00
```
kubectl exec -it mycluster-0 -n $DEMOSPACE -c sidecar -- mysqlsh root:sakila@127.0.0.1:3306 --sql -e " set persist_only time_zone='+08:00';"
kubectl exec -it mycluster-1 -n $DEMOSPACE -c sidecar -- mysqlsh root:sakila@127.0.0.1:3306 --sql -e " set persist_only time_zone='+08:00';"
kubectl exec -it mycluster-2 -n $DEMOSPACE -c sidecar -- mysqlsh root:sakila@127.0.0.1:3306 --sql -e " set persist_only time_zone='+08:00';"
```

- Restart the Cluster
```
kubectl rollout restart statefulset mycluster -n $DEMOSPACE
kubectl get pod -n $DEMOSPACE --watch
```
Wait until all pods restarted [terminated and running again ] and press **CTRL-C** to stop watching

- Check the timezone again!!!
```
kubectl exec -it mycluster-0 -n $DEMOSPACE -c sidecar -- mysqlsh root:sakila@127.0.0.1:3306 --sql -e " select @@hostname, @@time_zone;"
kubectl exec -it mycluster-1 -n $DEMOSPACE -c sidecar -- mysqlsh root:sakila@127.0.0.1:3306 --sql -e " select @@hostname, @@time_zone;"
kubectl exec -it mycluster-2 -n $DEMOSPACE -c sidecar -- mysqlsh root:sakila@127.0.0.1:3306 --sql -e " select @@hostname, @@time_zone;"
```


8. Deletion of Innodb Cluster
The deletion of Innodb Cluster (ic) using helm thru 'delete' command.   Please wait and check all resource to be deleted.
The presistent volumn claim (pvc) MUST be removed after the deletion.  

```
helm delete mycluster -n $DEMOSPACE
```

- Check if all pods, cronjob and ic removed
```
kubectl get pod -n $DEMOSPACE --watch
kubectl get ic -n $DEMOSPACE
kubectl get cronjob -n $DEMOSPACE
kubectl get pvc -n $DEMOSPACE
```
  - The pvc is always available and you need to remove it in the next step.


- Remove the Presistent Volumn Claim
```
kubectl delete pvc datadir-mycluster-0 -n $DEMOSPACE
kubectl delete pvc datadir-mycluster-1 -n $DEMOSPACE
kubectl delete pvc datadir-mycluster-2 -n $DEMOSPACE
```

Deletion of registry secret and backup-api-key can be done as follows

- listing the secret with namespace $DEMOSPACE
```
kubectl get secret -n $DEMOSPACE
```

- delete the registry secret created previously named as mysql-registry-secret
```
kubectl delete mysql-registry-secret -n $DEMOSPACE
```

- delete the backup api key created previously named as backup-apikey
```
kubectl delete backup-apikey -n $DEMOSPACE
```

- delete finished jobs
```
kubectl delete jobs --field-selector status.successful=1 -n $DEMOSPACE
```

# Done - you have finished deployment using enterprise package
---
For more tips about troubleshooting and notes : check [here](tips.md)
