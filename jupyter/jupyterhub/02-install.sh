helm upgrade --cleanup-on-fail \
  --install  myjupyterhub bitnami/jupyterhub \
  --namespace ${1} \
  --create-namespace \
  --values config.values
