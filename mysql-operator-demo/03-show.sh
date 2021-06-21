PGM=`basename $0`
if [ $# -ne 1 ]
then
	echo "Usage : $PGM <namespace>"
	exit
fi
kubectl get all -n $1

kubectl get ic -n $1
kubectl get pvc -n $1
kubectl get pod -n $1
kubectl get statefulset -n $1
