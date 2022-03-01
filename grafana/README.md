# Creating Grafana container
## create namespace grafana
## deploy grafan.yaml
## Checking the external public IP from loadbalancer service
## Accessing grafana via http://<external ip>:3000
### login as admin/admin

```
kubectl create  grafana
kubectl apply -f grafana.yaml -n grafana
kubectl get all -n grafana
kubectl get service -n grafana --watch

```

# Install Plugins (piechart and plotly) to grafana using cli
```
PODNAME=`kubectl get pod -o custom-columns=name:.metadata.name  -n grafana|sed -n '$p'`

kubectl exec -it $PODNAME -n grafana -- /bin/bash -c "grafana-cli plugins install natel-plotly-panel"
kubectl exec -it $PODNAME -n grafana -- /bin/bash -c "grafana-cli plugins install grafana-piechart-panel"

kubectl rollout restart deployment/grafana -n grafana
```
