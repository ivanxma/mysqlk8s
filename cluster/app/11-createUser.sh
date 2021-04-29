# create user node'%' identified by 'pass';
# grant all on *.* to node@'%';
echo "ls" | kubectl exec -it -n $1 mycluster-0  -- bash


