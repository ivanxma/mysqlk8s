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
  - when you have a stucked operation in mysql-operator.  Any further IC creation will just be stopped.  The kubectl get ic -n <namespace> will show the entry but no number with online [ not even a 0 ].   Restart the mysql-operator will make it continue.

- kubectl logs statefulsets mycluster -n [your namespace] 
  - to show directly the mycluster-0 logs.

- kubectl get cronjob -n <namespace>  
  - to show if the backup schedule job if it is created.

- kubectl edit cronjob <the cronjob> -n <namespace>  
  - to edit the schdule  [the patching / or edit the ic for schedule does not take any effect

- kubectl edit ic mycluster -n <namespace> 
  - to make changes on the ic configuration.  Some may be ignored <e.g. mycnf or schedule,etc..>

- Login to pod container sidecar / mysql
  - kubectl exec -it mycluster-0 -c mysql -n <namespace> -- bash  
    . to login bash with the pod mycluster-0 on container 'mysql'
  - kubectl exec -it mycluster-0 -c sidecar -n <namespace> -- bash  
    . to login bash with the pod mycluster-0 on container 'sidecar'

- kubectl rollout restart statefulsets mycluster -n [namespace]
  - To restart whole cluster











Reply…




