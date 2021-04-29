# create user node'%' identified by 'pass';
# grant all on *.* to node@'%';
 kubectl exec -it -n $1 mycluster-0  -- mysqlsh --sql myroot:Welcome1!@localhost -e "create user if not exists node@'%' identified by 'pass'; grant all on *.* to node@'%';"



