helm show values mysql-operator/mysql-innodbcluster > ic.values
helm install mycluster mysql-operator/mysql-innodbcluster --namespace myic --create-namespace --set credentials.root.user='root' --set credentials.root.password='supersecret'     --set credentials.root.host='%'     --set serverInstances=3     --set routerInstances=1 --set tls.useSelfSigned=true
