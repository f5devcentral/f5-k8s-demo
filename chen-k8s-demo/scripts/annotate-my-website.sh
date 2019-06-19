kubectl annotate configmap my-website  virtual-server.f5.com/ip=`kubectl get svc my-website -o json |jq ".spec.clusterIP" -r` --overwrite;
#kubectl annotate configmap my-website  virtual-server.f5.com/ip=10.100.253.168 --overwrite;
kubectl annotate configmap my-website  custom_dns=www.f5demo.com --overwrite;
kubectl annotate configmap my-website  custom_translate_ip=10.1.10.80 --overwrite;
