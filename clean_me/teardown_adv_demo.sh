#!/bin/sh
kubectl delete -f app1-configmap-bad.yaml
kubectl delete -f app1-service.yaml
kubectl delete -f app1-deployment.yaml
sleep 3
kubectl delete -f my-website-configmap.yaml
kubectl delete -f my-website-service.yaml
kubectl delete -f my-website-deployment.yaml
sleep 3
kubectl delete -f f5-ingress.yaml
sleep 3
python custom_automation.py  --host 10.1.10.60
sleep 10
# dns
echo curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/wideip/a/~Common~my-frontend.f5demo.com
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/wideip/a/~Common~my-frontend.f5demo.com
sleep 3
echo curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/wideip/a/~Common~www.f5demo.com
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/wideip/a/~Common~www.f5demo.com
sleep 3
echo curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/wideip/a/~Common~app1.f5demo.com
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/wideip/a/~Common~app1.f5demo.com
sleep 3

echo curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/pool/a/~Common~my-frontend_pool
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/pool/a/~Common~my-frontend_pool
sleep 3
echo curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/pool/a/~Common~my-website_pool
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/pool/a/~Common~my-website_pool
sleep 3
echo curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/pool/a/~Common~app1_pool
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/pool/a/~Common~app1_pool
sleep 3

echo curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/server/~Common~bigip/virtual-servers/my-frontend_vs
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/server/~Common~bigip/virtual-servers/my-frontend_vs
sleep 3
echo curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/server/~Common~bigip/virtual-servers/my-website_vs
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/server/~Common~bigip/virtual-servers/my-website_vs
sleep 3
echo curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/server/~Common~bigip/virtual-servers/app1_vs
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/gtm/server/~Common~bigip/virtual-servers/app1_vs
sleep 3
echo curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/sys/application/service/~Common~k8s_demo.app~k8s_demo
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/sys/application/service/~Common~k8s_demo.app~k8s_demo
sleep 3
