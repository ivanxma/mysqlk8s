# This demo is to install AUDIT plugin 
##  in MySQL InnoDB Cluster created from MySQL Operator
##  Assuming a running cluster as "mycluster" in namespace as "mydemo"

- Setup env DEMOSPACE as "mydemo" and CLUSTERNAME as "mycluster"
```
export DEMOSPACE=mydemo
export CLUSTERNAME=mycluster
export USER=root
export PASSWORD=password
```

### Check if InnoDB Cluster is ONLINE
```
kubectl get ic $CLUSTERNAME -n $DEMOSPACE
```

### Install audit on Primary Node
- the $CLUSTERNAME is the service name to ROUTER service.  The script will be executed on Primary Node and install the MySQL Audit Plugin
```
kubectl exec -it ${CLUSTERNAME}-0 -c mysql -n ${DEMOSPACE}  -- mysql -u $USER -p $PASSWORD -h $CLUSTERNAME -e "source /usr/share/mysql-8.0/audit_log_filter_linux_install.sql"
```

### Config change to include plugin_load_add=audit_log.so
```
kubectl edit ConfigMap ${CLUSTERNAME}-initconf -n ${DEMOSPACE}
```
- Locate the section 99-extra.cnf: | and append the following to the section
  - Note about the spacing and align properly without using [Tab]
```
  [mysqld]
  plugin_load_add=audit_log.so
```

### Restart the statefulset
```
kubectl rollout restart statefulset $CLUSTERNAME -n $DEMOSPACE
```

### Check if audit plugin is loaded for all nodes
- Showing variables from audit plugins
```
kubectl exec -it ${CLUSTERNAME}-0 -n ${DEMOSPACE} -c sidecar -- mysqlsh ${USER}:${PASSWORD}@127.0.0.1 --sql -e "show variables like 'audit%';"
kubectl exec -it ${CLUSTERNAME}-1 -n ${DEMOSPACE} -c sidecar -- mysqlsh ${USER}:${PASSWORD}@127.0.0.1 --sql -e "show variables like 'audit%';"
kubectl exec -it ${CLUSTERNAME}-2 -n ${DEMOSPACE} -c sidecar -- mysqlsh ${USER}:${PASSWORD}@127.0.0.1 --sql -e "show variables like 'audit%';"
```
- Showing the audit.log 
```
kubectl exec -it ${CLUSTERNAME}-0 -n ${DEMOSPACE} -c mysql -- sh -c "cat  /var/lib/mysql/audit.log"
kubectl exec -it ${CLUSTERNAME}-1 -n ${DEMOSPACE} -c mysql -- sh -c "cat  /var/lib/mysql/audit.log"
kubectl exec -it ${CLUSTERNAME}-2 -n ${DEMOSPACE} -c mysql -- sh -c "cat  /var/lib/mysql/audit.log"
```

### Scaling the Cluster from 3 to 5
```
kubectl edit ic ${CLUSTERNAME} -n ${DEMOSPACE}
```
- replace "instances: 3" as "instances: 5"
- Save it and quit edit
- Note the change the IC Online status and the number of instance grows from 3 to 5
```
kubectl get ic ${CLUSTERNAME} -n ${DEMOSPACE}
```

- At this point, if all is online, you will be able to find node 4 and node 5 having the audit installed and running as secondary nodes in the cluster.






