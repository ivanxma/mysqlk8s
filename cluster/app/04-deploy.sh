sed "s/NSNAME/$1/g" deploy-app.yaml |kubectl apply -n $1 -f -
kubectl apply -f lb.yaml -n $1
