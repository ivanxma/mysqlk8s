PODNAME=`kubectl get pod -o custom-columns=name:.metadata.name  -n grafana|sed -n '$p'`

kubectl exec -it $PODNAME -n grafana -- /bin/bash -c "grafana-cli plugins install natel-plotly-panel"
kubectl exec -it $PODNAME -n grafana -- /bin/bash -c "grafana-cli plugins install grafana-piechart-panel"

kubectl rollout restart deployment/grafana -n grafana

