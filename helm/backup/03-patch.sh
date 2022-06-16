. ./env.sh
kubectl patch ic mycluster -n $DEMOSPACE --patch-file mypatch.yaml --type='merge'
