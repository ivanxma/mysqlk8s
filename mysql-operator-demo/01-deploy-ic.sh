PGM=`basename $0`
if [ $# -ne 1 ]
then
	echo "Usage : $PGM <namespace>"
	exit
fi
#kubectl apply -f ./sample-cluster.yaml -n $1
# The secret should have been applied when it is created!
#kubectl apply -f mydockersecret.yaml -n $1

kubectl apply -f ./ic1.yaml -n $1
kubectl apply -f ./ic2.yaml -n $1
