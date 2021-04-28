
 kubectl create namespace $1

 kubectl create secret docker-registry 'ivanma-secret-mysql-operator' -n $1 --docker-server=iad.ocir.io --docker-username='idazzjlcjqzj/oracleidentitycloudservice/ivan-cs.ma@oracle.com' --docker-password='E5MI3#i5OhF8Kuje]}:;'

kubectl create secret -n $1 generic mypwds  --from-literal=rootUser=myroot  --from-literal=rootHost=%  --from-literal=rootPassword=Welcome1! 
