#!/bin/bash

##
## Use this script to automatically: 
## 1- Deploy F5 CC 
## 2- Deploy our frontend-app using BIG-IP 
## 3- Deploy our ASPs
## 4- Replace kube-proxy
## 5- Deploy our backend application using ASP
##

##
## Create F5 kubernetes partition
##
curl -k -u admin:admin -H "Content-Type: application/json" -X POST -d '{"name":"kubernetes", "fullPath": "/kubernetes", "subPath": "/"}' https://10.1.10.240/mgmt/tm/sys/folder |python -m json.tool
#
# Setup Flannel
#

# disable vxlan configsync on each device
curl -k -u admin:admin -H "Content-Type: application/json" -X PUT -d '{"value":"disable"}' https://10.1.10.240/mgmt/tm/sys/db/iptunnel.configsync 
curl -k -u admin:admin -H "Content-Type: application/json" -X PUT -d '{"value":"disable"}' https://10.1.10.241/mgmt/tm/sys/db/iptunnel.configsync 
curl -k -u admin:admin -H "Content-Type: application/json" -X POST -d '{"name": "fl-vxlan","partition": "Common","defaultsFrom": "/Common/vxlan", "floodingType": "none","port": 8472 }' https://10.1.10.240/mgmt/tm/net/tunnels/vxlan
sleep 3
# sync
curl -k -u admin:admin -H 'Content-Type: application/json' -X POST -d '{"command":"run","options":[{"force-full-load-push to-group":"Sync"}]}' "https://10.1.10.240/mgmt/tm/cm/config-sync"
sleep 3
curl -k -u admin:admin  -H 'Content-Type: application/json' -X POST -d '{"name": "flannel_vxlan","partition": "Common","key": 1,"localAddress": "10.1.10.240","profile": "/Common/fl-vxlan" }' https://10.1.10.240/mgmt/tm/net/tunnels/tunnel

curl -k -u admin:admin  -H 'Content-Type: application/json' -X POST -d '{"name": "flannel_vxlan","partition": "Common","key": 1,"localAddress": "10.1.10.241","profile": "/Common/fl-vxlan" }' https://10.1.10.241/mgmt/tm/net/tunnels/tunnel
sleep 10
curl  curl --stderr /dev/null -k -u admin:admin -H "Content-Type: application/json"  "https://10.1.10.240/mgmt/tm/sys" | jq .selfLink -r | grep -E ver=1[23]
if [ $? != 0 ]
  then
  # v13
  macAddr1=$(curl --stderr /dev/null -k -u admin:admin -H "Content-Type: application/json"  "https://10.1.10.240/mgmt/tm/net/tunnels/tunnel/~Common~flannel_vxlan/stats?options=all-properties"|jq '.entries."https://localhost/mgmt/tm/net/tunnels/tunnel/~Common~flannel_vxlan/~Common~flannel_vxlan/stats"."nestedStats".entries.macAddr.description' -r)
  macAddr2=$(curl --stderr /dev/null -k -u admin:admin -H "Content-Type: application/json"  "https://10.1.10.241/mgmt/tm/net/tunnels/tunnel/~Common~flannel_vxlan/stats?options=all-properties"|jq '.entries."https://localhost/mgmt/tm/net/tunnels/tunnel/~Common~flannel_vxlan/~Common~flannel_vxlan/stats"."nestedStats".entries.macAddr.description' -r)
else
  macAddr1=$(curl --stderr /dev/null -k -u admin:admin -H "Content-Type: application/json"  "https://10.1.10.240/mgmt/tm/net/tunnels/tunnel/~Common~flannel_vxlan/stats?options=all-properties"|jq '.entries."https://localhost/mgmt/tm/net/tunnels/tunnel/~Common~flannel_vxlan/stats"."nestedStats".entries.macAddr.description' -r)
  macAddr2=$(curl --stderr /dev/null -k -u admin:admin -H "Content-Type: application/json"  "https://10.1.10.241/mgmt/tm/net/tunnels/tunnel/~Common~flannel_vxlan/stats?options=all-properties"|jq '.entries."https://localhost/mgmt/tm/net/tunnels/tunnel/~Common~flannel_vxlan/stats"."nestedStats".entries.macAddr.description' -r)
  fi

#
# Create bigip node (vxlan)
#

sed -e "s/MAC_ADDR/$macAddr1/g" bigip1-node.yaml |kubectl create -f -
sed -e "s/MAC_ADDR/$macAddr2/g" bigip2-node.yaml |kubectl create -f -

# Create self-ip

curl -k -u admin:admin  -H 'Content-Type: application/json' -X POST -d '{"name": "vxlan-local","partition": "Common","address": "10.233.125.15/18", "floating": "disabled","vlan": "/Common/flannel_vxlan"}' https://10.1.10.240/mgmt/tm/net/self
#curl -k -u admin:admin  -H 'Content-Type: application/json' -X POST -d '{"name": "vxlan-floating","partition": "Common","address": "10.244.30.16/16", "floating": "enabled","vlan": "/Common/flannel_vxlan","trafficGroup":"/Common/traffic-group-1"}' https://10.1.10.240/mgmt/tm/net/self

curl -k -u admin:admin  -H 'Content-Type: application/json' -X POST -d '{"name": "vxlan-local","partition": "Common","address": "10.233.126.15/18", "floating": "disabled","vlan": "/Common/flannel_vxlan"}' https://10.1.10.241/mgmt/tm/net/self
#curl -k -u admin:admin  -H 'Content-Type: application/json' -X POST -d '{"name": "vxlan-floating","partition": "Common","address": "10.244.31.16/16", "floating": "enabled","vlan": "/Common/flannel_vxlan","trafficGroup":"/Common/traffic-group-1"}' https://10.1.10.241/mgmt/tm/net/self



#
# Create serviceaccount
#

#kubectl create serviceaccount bigip-ctlr -n kube-system
#kubectl create -f f5-k8s-sample-rbac.yaml

##
## Create BIG-IP kubectl secret
##

printf "##############################################\n"
printf "Create BIG-IP secret\n"
printf "##############################################\n\n\n"

kubectl create secret generic bigip-login --namespace kube-system --from-literal=username=admin --from-literal=password=admin

##
## Deploy F5 BIG-IP CC
##

printf "##############################################\n"
printf "Deploy BIG-IP CC\n"
printf "##############################################\n\n\n"

kubectl create -f f5-cc-deployment.yaml -n kube-system
kubectl create -f f5-cc-deployment2.yaml -n kube-system

##
## Deploy NGINX Ingress Controller
##

kubectl apply -f nginx/ns-and-sa.yaml
kubectl apply -f nginx/default-server-secret.yaml
kubectl apply -f nginx/nginx-config.yaml
kubectl apply -f nginx/custom-resource-definitions.yaml
kubectl apply -f nginx/rbac.yaml
kubectl apply -f nginx/nginx-ingress.yaml
kubectl apply -f nginx/nginx-configuration-configmap.yaml -n nginx-ingress
kubectl apply -f nginx/ingress-nginx-service.yaml
kubectl apply -f nginx/ingress-nginx-service-tls.yaml

##
## Deploy our frontend application and associate the relevant service/configmap to setup the BIG-IP
##

printf "##############################################\n"
printf "Deploy FRONTEND APP\n"
printf "##############################################\n\n\n"

kubectl create -f my-frontend-deployment.yaml

#kubectl create -f my-frontend-configmap.yaml

#kubectl create -f as3-configmap.yaml

kubectl create -f my-frontend-service-as3.yaml


kubectl create -f my-website-deployment.yaml

kubectl create -f my-website-service.yaml

##
## Deploy ASP and the relevant configmap
##

#printf "##############################################\n"
#printf "Deploy ASP\n"
#printf "##############################################\n\n\n"
#
#kubectl create -f f5-asp-configmap.yaml
#
#kubectl create -f f5-asp-daemonset.yaml

##
## Replace kube-proxy with our kube-proxy
##
#printf "##############################################\n"
#printf "Deploy F5 KUBE PROXY\n"
#printf "##############################################\n\n\n"


#kubectl delete -f kube-proxy-origin.yaml

#kubectl create -f f5-kube-proxy-ds.yaml

##
## Deploy backend application leveraging ASP
##

printf "##############################################\n"
printf "Deploy BACKEND\n"
printf "##############################################\n\n\n"

kubectl create -f my-backend-deployment.yaml

kubectl create -f my-backend-service.yaml

curl -k -u admin:admin -H 'Content-Type: application/json' -X POST -d '{"command":"run","options":[{"to-group":"Sync"}]}' "https://10.1.10.240/mgmt/tm/cm/config-sync"
sleep 3
curl -k -u admin:admin -H "Content-Type: application/json" -d '{"command":"save"}' https://10.1.10.240/mgmt/tm/sys/config

printf "##############################################\n"
printf "Connect to Frontend APP with http://10.1.10.80\n"
printf "##############################################\n\n\n"

printf "##############################################\n"
printf "Deploy INGRESS\n"
printf "##############################################\n\n\n"

kubectl create -f node-blue.yaml
kubectl create -f node-green.yaml
kubectl create -f blue-ingress-nginx.yaml
kubectl create -f green-ingress-nginx.yaml
#kubectl create -f blue-green-ingress.yaml
#kubectl create -f blue-green-ingress-tls.yaml

printf "##############################################\n"
printf "Using command: kubectl get pods --all-namespaces to check containers status\n"
printf "Make sure that everything is up and running\n"
printf "Wait for all containers related to the demo to be in running mode\n"
printf "##############################################\n\n\n"
kubectl get pods --all-namespaces
