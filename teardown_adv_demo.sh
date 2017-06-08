#!/bin/sh
# dns
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/wideip/a/~Common~my-frontend.f5demo.com
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/wideip/a/~Common~www.f5demo.com
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/wideip/a/~Common~app1.f5demo.com

curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/pool/a/~Common~my-frontend_pool
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/pool/a/~Common~my-website_pool
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/pool/a/~Common~app1_pool

curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/server/~Common~bigip/virtual-servers/my-frontend_vs
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/server/~Common~bigip/virtual-servers/my-website_vs
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/server/~Common~bigip/virtual-servers/app1_vs
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/sys/application/service/~Common~k8s_demo.app~k8s_demo

kubectl delete -f app1-configmap.yaml
kubectl delete -f app1-service.yaml
kubectl delete -f app1-deployment.yaml
kubectl delete -f my-website-configmap.yaml
kubectl delete -f my-website-service.yaml
kubectl delete -f my-website-deployment.yaml

python custom_automation.py  --host 10.1.10.60
