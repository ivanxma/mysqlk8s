kubectl create secret -n $1 generic wordpress-mysql-root-password  --from-literal=rootUser=wordpress  --from-literal=rootHost=%  --from-literal=rootPassword=wordpress
