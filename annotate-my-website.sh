#kubectl annotate configmap my-website  virtual-server.f5.com/ip=`kubectl get svc my-website -o json |jq ".spec.clusterIP" -r` --overwrite;
kubectl annotate configmap my-website  virtual-server.f5.com/ip=10.100.253.168 --overwrite;
