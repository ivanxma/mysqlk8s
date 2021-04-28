kubectl patch pod $1  -n $2 -p '{"metadata":{"finalizers":null}}'
