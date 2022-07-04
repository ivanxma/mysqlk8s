# Some troubleshooting tips :
- kubectl logs deployment/mysql-operator -n mysql-operator
  - to show the logs for the mysql-operator deployment

- kubectl edit ic mycluster -n {your namespace]    
  - change the ic definition.   You may want to remove the line finalizer when there is hang with deletion.  In particularly, when you have failure with install and node is not up and running then you are trying to delete.  kopf will continue to connect to non-exists node and termination cannot be finalized.   So you need to remove the finalizer.
  ```
  # kubectl get ic -n mydemo
  NAME        STATUS   ONLINE   INSTANCES   ROUTERS   AGE
  mycluster                     3           1         5m59s
  ```

- kubectl rollout restart deployment mysql-operator -n mysql-operator 
  - when you have a stucked operation in mysql-operator.  Any further IC creation will just be stopped.  The kubectl get ic -n [namespace] will show the entry but no number with online [ not even a 0 ].   Restart the mysql-operator will make it continue.

- kubectl logs statefulsets mycluster -n [your namespace] 
  - to show directly the mycluster-0 logs.

- kubectl get cronjob -n [namespace]  
  - to show if the backup schedule job if it is created.

- kubectl edit cronjob [the cronjob] -n [namespace] 
  - to edit the schdule  [the patching / or edit the ic for schedule does not take any effect

- kubectl edit ic mycluster -n [namespace]
  - to make changes on the ic configuration.  Some may be ignored [e.g. mycnf ]

- Login to pod container sidecar / mysql
  - kubectl exec -it mycluster-0 -c mysql -n [namespace] -- bash  
    . to login bash with the pod mycluster-0 on container 'mysql'
  - kubectl exec -it mycluster-0 -c sidecar -n [namespace] -- bash  
    . to login bash with the pod mycluster-0 on container 'sidecar'

- kubectl rollout restart statefulsets mycluster -n [namespace]
  - to restart whole cluster

- helm list --all-namespaces
  - to show all the helm application in all namespaces  

- helm list -n [your namespace]
  - to list only the application in your namespace

---

## Scenarios 

### --dry-run with helm does not interact with the kubernetes cluster
- Even though you may have the secret object created, the error message is still there.   The template has the lookup function to check if there is any valid secret object in the namespace.
```
helm install mycluster ./mysql-innodbcluster-2.0.4.tgz -f ic.values -n mydemo --dry-run
Error: INSTALLATION FAILED: execution error at (mysql-innodbcluster/templates/service_account_cluster.yaml:16:8): image.pullSecrets.secretName: secret 'mysql-registry-secret' not found in namespace 'mydemo'
```

### When you delete innodb cluster using helm e.g. helm delete mycluster -n [your namespace],
###   if the cronjob configured with schedule backup is still there.  You may want to remove it.
```
kubectl get cronjob -n [your namespace]
kubectl delete cronjob [the job] -n [your namespace]
```

### If there are many job.batch with Completed status, it can be a long list and you want to remove them
```
kubectl delete jobs --field-selector status.successful=1 -n [your namespace]
```

### If ic status as INITIALIZING for long time and pods (mycluster-0, mycluster-1, mycluster-2) pods are running with router pod not running, check the following

  - If the pvc under the [namespace] was not clean up with previous installed innodb cluster, the re-installation of innodb cluster will reuse the same pvc/pv.  This is because deletion of Innodb cluster does not remove pvc.   Therefore, you need to delete the innodb cluster again and clean up the pvc.  With clean environment, you can reinstall Innodb cluster again
  - To delete IC which it is hanging.  You need to remove the finalizer from IC defintion for your namespace

