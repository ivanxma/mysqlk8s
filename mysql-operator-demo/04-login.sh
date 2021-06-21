PGM=`basename $0`
if [ $# -ne 1 ]
then
	echo "Usage : $PGM <namespace>"
	exit
fi
kubectl exec -it -n $1 mycluster-0 -- mysqlsh --uri myroot:Welcome1!@mycluster.${1}.svc.cluster.local:6446
