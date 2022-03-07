helm repo add stable https://charts.helm.sh/stable
kubectl create ns ingress1
kubectl create ns ingress2
kubectl create ns ingress3
helm install stable/nginx-ingress --set controller.ingressClass=first --namespace ingress1 --set controller.replicaCount=2 --set rbac.create=false --generate-name
helm install stable/nginx-ingress --set controller.ingressClass=second --namespace ingress2 --set controller.replicaCount=2 --set rbac.create=false --generate-name
helm install stable/nginx-ingress --set controller.ingressClass=third --namespace ingress3 --set controller.replicaCount=2 --set rbac.create=false --generate-name
