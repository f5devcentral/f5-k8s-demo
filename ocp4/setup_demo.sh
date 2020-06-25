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
curl -k -u admin:admin -H "Content-Type: application/json" -X POST -d '{"name":"ocp", "fullPath": "/ocp", "subPath": "/"}' https://10.1.10.240/mgmt/tm/sys/folder | jq .
#
# Setup Flannel
#


curl -k -u admin:admin -H "Content-Type: application/json" -X POST -d '{"name": "ose-vxlan","partition": "Common","defaultsFrom": "/Common/vxlan", "floodingType": "multipoint" }' https://10.1.10.240/mgmt/tm/net/tunnels/vxlan
sleep 3

curl -k -u admin:admin  -H 'Content-Type: application/json' -X POST -d '{"name": "openshift_vxlan","partition": "Common","key": 0,"localAddress": "10.1.20.240","profile": "/Common/ose-vxlan" }' https://10.1.10.240/mgmt/tm/net/tunnels/tunnel
#
oc create -f host.yaml
sleep 30
SUBNET=$(oc get hostsubnet bigip1 -o template --template={{.subnet}})
SELFLOCAL=$(echo $SUBNET | sed -e 's/\.0\/23/\.3\/14/g')
SELFFLOAT=$(echo $SUBNET | sed -e 's/\.0\/23/\.4\/14/g')

# Create self-ip

curl -k -u admin:admin  -H 'Content-Type: application/json' -X POST -d "{\"name\": \"vxlan-local\",\"partition\": \"Common\",\"address\": \"${SELFLOCAL}\", \"floating\": \"disabled\",\"vlan\": \"/Common/openshift_vxlan\"}" https://10.1.10.240/mgmt/tm/net/self
curl -k -u admin:admin  -H 'Content-Type: application/json' -X POST -d "{\"name\": \"vxlan-float\",\"partition\": \"Common\",\"address\": \"${SELFFLOAT}\", \"floating\": \"enabled\",\"vlan\": \"/Common/openshift_vxlan\",\"trafficGroup\":\"/Common/traffic-group-1\"}" https://10.1.10.240/mgmt/tm/net/self


sleep 10

##
## Create BIG-IP kubectl secret
##

printf "##############################################\n"
printf "Create BIG-IP secret\n"
printf "##############################################\n\n\n"

oc create secret generic bigip-login --namespace kube-system --from-literal=username=admin --from-literal=password=admin

##
## Deploy F5 BIG-IP CC
##

printf "##############################################\n"
printf "Deploy BIG-IP CC\n"
printf "##############################################\n\n\n"

oc create -f cis-operator.yaml
sleep 30
oc create -f f5-server.yaml
##
## Deploy NGINX Ingress Controller
##
oc create ns nginx-ingress
oc create -f nginx-operator.yaml
safesub=$(echo $SUBNET |sed -e 's/\//\\\//g')
cat nginx-ingress-controller.yaml| sed -e 's/10\.130\.0\.0\/23/'"$safesub"'/g' | oc create -f -
##
## Deploy our frontend application and associate the relevant service/configmap to setup the BIG-IP
##

printf "##############################################\n"
printf "Deploy FRONTEND APP\n"
printf "##############################################\n\n\n"

oc create -f my-frontend-deployment2.yaml
oc create -f my-frontend-deployment3.yaml
oc create -f my-frontend-deployment.yaml
oc create -f www-deployment.yaml

oc create -f ingress-nginx-service-tls.yaml
oc create -f ingress-nginx-service.yaml
oc create -f my-frontend-service2-as3.yaml
oc create -f my-frontend-service3-as3.yaml
oc create -f my-frontend-service.yaml
oc create -f www-service.yaml


sleep 3
curl -k -u admin:admin -H "Content-Type: application/json" -d '{"command":"save"}' https://10.1.10.240/mgmt/tm/sys/config

printf "##############################################\n"
printf "Connect to Frontend APP with http://10.1.10.80\n"
printf "##############################################\n\n\n"

printf "##############################################\n"
printf "Deploy INGRESS\n"
printf "##############################################\n\n\n"

oc create -f blue-ingress-nginx.yaml -n nginx-ingress
oc create -f green-ingress-nginx.yaml -n nginx-ingress
oc create -f node-blue.yaml -n nginx-ingress
oc create -f node-green.yaml -n nginx-ingress
oc create secret tls -n nginx-ingress tls-secret --cert=/home/centos/blue-bundle.crt --key=/home/centos/blue.key

oc create -f as3-configmap-basic.yaml
oc create -f as3-configmap-override-route.yaml

oc create -f my-route.yaml
oc create -f www-route.yaml

printf "##############################################\n"
printf "Using command: kubectl get pods --all-namespaces to check containers status\n"
printf "Make sure that everything is up and running\n"
printf "Wait for all containers related to the demo to be in running mode\n"
printf "##############################################\n\n\n"
oc get po -o wide
oc get po -n kube-system
