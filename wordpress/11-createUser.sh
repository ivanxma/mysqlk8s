# create user wordpress'%' identified by 'wordpress';
# grant all on *.* to wordpress@'%';
 kubectl exec -it -n $1 mycluster-0  -- mysqlsh --sql myroot:Welcome1!@localhost -e "drop user if exists wordpress@'%'; create user if not exists wordpress@'%' identified with mysql_native_password by 'wordpress'; grant all on *.* to wordpress@'%';create database if not exists wordpress;"



