kubectl annotate configmap my-frontend  virtual-server.f5.com/ip=`kubectl get svc my-frontend -o json |jq ".spec.clusterIP" -r` --overwrite;
