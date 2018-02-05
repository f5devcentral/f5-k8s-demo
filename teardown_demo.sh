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
## Deploy backend application leveraging ASP
##

printf "##############################################\n"
printf "Delete BACKEND\n"
printf "##############################################\n\n\n"

kubectl delete -f my-backend-deployment.yaml

kubectl delete -f my-backend-service.yaml

##
## Replace kube-proxy with original kube-proxy
##
#printf "##############################################\n"
#printf "Restore KUBE PROXY\n"
#printf "##############################################\n\n\n"
#
#kubectl delete -f f5-kube-proxy-ds.yaml
#
#kubectl create -f kube-proxy-origin.yaml

##
## Deploy ASP and the relevant configmap
##

#printf "##############################################\n"
#printf "Delete ASP\n"
#printf "##############################################\n\n\n"

#kubectl delete -f f5-asp-configmap.yaml
#
#kubectl delete -f f5-asp-daemonset.yaml

##
## Deploy our frontend application and associate the relevant service/configmap to setup the BIG-IP
## 

printf "##############################################\n"
printf "Delete FRONTEND APP\n"
printf "##############################################\n\n\n"

kubectl delete -f my-frontend-configmap.yaml

kubectl delete -f my-frontend-service.yaml

kubectl delete -f my-frontend-deployment.yaml

printf "##############################################\n"
printf "Delete Ingress\n"
printf "##############################################\n\n\n"

kubectl delete -f blue-green-ingress.yaml
kubectl delete -f node-blue.yaml
kubectl delete -f node-green.yaml


##
## Delete F5 BIG-IP CC
##

printf "##############################################\n"
printf "Delete BIG-IP CC\n"
printf "##############################################\n\n\n"
sleep 30
kubectl delete -f f5-cc-deployment.yaml
kubectl delete -f f5-cc-deployment2.yaml

##
## Delete BIG-IP kubectl secret
##

printf "##############################################\n"
printf "Create BIG-IP secret\n"
printf "##############################################\n\n\n"

kubectl delete secret bigip-login -n kube-system

kubectl delete serviceaccount bigip-ctlr -n kube-system
kubectl delete -f  f5-k8s-sample-rbac.yaml

##
## Delete F5 kubernetes partition
##

curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/ltm/rule/~kubernetes~http_redirect_irule
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/ltm/data-group/internal/~kubernetes~https_redirect_dg
sleep 30
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/sys/folder/~kubernetes


# delete vxlan profile

curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/net/self/~Common~vxlan-floating
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/net/self/~Common~vxlan-local

curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.61/mgmt/tm/net/self/~Common~vxlan-floating
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.61/mgmt/tm/net/self/~Common~vxlan-local

 curl -k -u admin:admin -H "Content-Type: application/json" -X PATCH -d '{"records":{}}' https://10.1.10.60/mgmt/tm/net/fdb/tunnel/~Common~flannel_vxlan
 curl -k -u admin:admin -H "Content-Type: application/json" -X PATCH -d '{"records":{}}' https://10.1.10.61/mgmt/tm/net/fdb/tunnel/~Common~flannel_vxlan

curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/net/tunnels/tunnel/~Common~flannel_vxlan
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.61/mgmt/tm/net/tunnels/tunnel/~Common~flannel_vxlan
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.10.60/mgmt/tm/net/tunnels/vxlan/~Common~fl-vxlan


# enable vxlan configsync on each device
curl -k -u admin:admin -H "Content-Type: application/json" -X PUT -d '{"value":"enable"}' https://10.1.10.60/mgmt/tm/sys/db/iptunnel.configsync 
curl -k -u admin:admin -H "Content-Type: application/json" -X PUT -d '{"value":"enable"}' https://10.1.10.61/mgmt/tm/sys/db/iptunnel.configsync 

curl -k -u admin:admin -H 'Content-Type: application/json' -X POST -d '{"command":"run","options":[{"force-full-load-push to-group":"Sync"}]}' "https://10.1.10.60/mgmt/tm/cm/config-sync"
sleep 3
curl -k -u admin:admin -H "Content-Type: application/json" -d '{"command":"save"}' https://10.1.10.60/mgmt/tm/sys/config

#
# Delete bigip node (vxlan)
#
kubectl delete -f bigip1-node.yaml
kubectl delete -f bigip2-node.yaml

printf "##############################################\n"
printf "Connect to Frontend APP with http://10.1.10.80\n"
printf "##############################################\n\n\n"

printf "##############################################\n"
printf "Using command: kubectl get pods --all-namespaces to check containers status\n"
printf "Make sure that everything is up and running\n"
printf "Wait for all containers related to the demo to be in running mode\n"
printf "##############################################\n\n\n"
kubectl get pods --all-namespaces
