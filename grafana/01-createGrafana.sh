kubectl create ns  grafana
kubectl apply -f grafana.yaml -n grafana
kubectl get all -n grafana
kubectl get service -n grafana --watch

