kubectl apply -f pvc.yaml -n kafka
kubectl get pvc kafka
helm install kafka-demo --namespace kafka incubator/kafka -f https://raw.githubusercontent.com/helm/charts/master/incubator/kafka/values.yaml
