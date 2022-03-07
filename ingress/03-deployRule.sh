
cat <<EOF | kubectl apply -n $1 -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
 name: hello-world-ing
 annotations:
  kubernetes.io/ingress.class: "nginx"
spec:
 tls:
 - secretName: tls-secret
 rules:
 - http:
   paths:
    - path: $4
     pathType: Prefix
     backend:
      service:
       name: $2
       port:
        number: $3
EOF
