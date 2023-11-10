helm upgrade --cleanup-on-fail \
  --install  myjupyterhub jupyterhub/jupyterhub \
  --namespace myjupyterhub \
  --create-namespace \
  --values config.values
