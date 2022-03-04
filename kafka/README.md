# https://platform9.com/tutorials/how-to-set-up-and-run-kafka-on-kubernetes/
## namespace : kafka
## PresistentVolume
### kafka-pv-volume (10Gi) /mnt/data
### kafka-pv-volume-2 (10Gi) /mnt/data
### kafka-pv-volume-3 (10Gi) /mnt/data
## Using helm
### serviceaccount : 
```
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
```
### Helm chart - kafka Incubator Chart - https://github.com/helm/charts/tree/0ca37cc106467190bd705aff647d2c7361e1d6f1/incubator/kafka
```
helm repo add incubator helm  https://charts.helm.sh/incubator 
curl https://raw.githubusercontent.com/helm/charts/master/incubator/kafka/values.yaml > config.yml
helm install kafka-demo --namespace kafka incubator/kafka -f config.yml --debug
helm status kafka-demo -n kafka
```

## Testing the Kafka Cluster
### testclient.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: testclient
  namespace: kafka
spec:
  containers:
  - name: kafka
    image: solsson/kafka:0.11.0.0
    command:
      - sh
      - -c
      - "exec tail -f /dev/null"
```

### deploy and test
```
kubectl apply -f testclient.yaml
kubectl -n kafka exec -ti testclient -- ./bin/kafka-topics.sh --zookeeper kafka-demo-zookeeper:2181 --topic messages --create --partitions 1 --replication-factor 1
kubectl -n kafka exec -ti testclient -- ./bin/kafka-topics.sh --zookeeper kafka-demo-zookeeper:2181 --list
```

### Open terminal for message producer
```
kubectl -n kafka exec -ti testclient -- ./bin/kafka-console-consumer.sh --bootstrap-server kafka-demo:9092 --topic messages --from-beginning
```

### Open terminal for message consumer
```
kubectl -n kafka exec -ti testclient -- ./bin/kafka-console-producer.sh --broker-list kafka-demo:9092 --topic messages
```

## Delete the helm chart
```
helm delete kafka-demo --purge
kubectl delete ns kafka
```

## remove the pv
