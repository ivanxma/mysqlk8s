#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/cloud/deploy.yaml
PGM=`basename $0`

if [ $# -eq 0 ]
then
	echo "Usage : $PGM <namespace>"
	exit
fi

# create namespace
kubectl create ns $1

# deploy controller on namespace
curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/cloud/deploy.yaml|sed "s/namespace: ingress-nginx/namespace: $1/g" > ingress-$$.yaml

kubectl apply -f ingress-$$.yaml
rm ingress-$$.yaml
