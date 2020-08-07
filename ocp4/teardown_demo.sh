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
## Deploy our frontend application and associate the relevant service/configmap to setup the BIG-IP
## 

printf "##############################################\n"
printf "Delete FRONTEND APP\n"
printf "##############################################\n\n\n"

oc delete -f my-frontend-deployment2.yaml
oc delete -f my-frontend-deployment3.yaml
oc delete -f my-frontend-deployment.yaml
oc delete -f www-deployment.yaml

oc delete -f ingress-nginx-service-tls.yaml
oc delete -f ingress-nginx-service.yaml
oc delete -f my-frontend-service2-as3.yaml
oc delete -f my-frontend-service3-as3.yaml
oc delete -f my-frontend-service.yaml
oc delete -f www-service.yaml

printf "##############################################\n"
printf "Delete Ingress\n"
printf "##############################################\n\n\n"

oc delete -f blue-ingress-nginx.yaml -n nginx-ingress
oc delete -f green-ingress-nginx.yaml -n nginx-ingress
oc delete -f node-blue.yaml -n nginx-ingress
oc delete -f node-green.yaml -n nginx-ingress
oc delete -f appprotect-basic.yaml -n nginx-ingress
oc delete -f appprotect-log.yaml -n nginx-ingress

oc apply -f as3-configmap-empty.yaml
oc delete -f as3-configmap-override-route.yaml

oc delete -f my-route.yaml
oc delete -f www-route.yaml

##
## Delete F5 BIG-IP CC
##

printf "##############################################\n"
printf "Delete BIG-IP CC\n"
printf "##############################################\n\n\n"
sleep 30
oc delete -f as3-configmap-empty.yaml
oc delete -f f5-server.yaml
oc delete -f cis-operator.yaml
oc delete -f cis-subscription.yaml
##
## Remove NGINX
##

oc delete -f ingress-nginx-service.yaml -n nginx-ingress
oc delete -f ingress-nginx-service-tls.yaml -n nginx-ingress

oc delete -f nginx-ingress-controller.yaml -n nginx-ingress
oc delete secret -n nginx-ingress tls-secret -n nginx-ingress

oc delete -f nginx-operator.yaml -n nginx-ingress
oc delete -f nginx-subscription.yaml -n nginx-ingress
oc delete namespace nginx-ingress
oc label ns default use_cis-
sleep 3


##
## Delete BIG-IP kubectl secret
##

printf "##############################################\n"
printf "Delete BIG-IP secret\n"
printf "##############################################\n\n\n"

kubectl delete secret bigip-login -n kube-system

#kubectl delete serviceaccount bigip-ctlr -n kube-system
#kubectl delete -f  f5-k8s-sample-rbac.yaml

##
## Delete F5 kubernetes partition
##

#curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.20.240/mgmt/tm/ltm/rule/~kubernetes~http_redirect_irule
#curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.20.240/mgmt/tm/ltm/rule/~kubernetes~http_redirect_irule_443

#curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.20.240/mgmt/tm/ltm/data-group/internal/~kubernetes~https_redirect_dg
sleep 30
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.20.240/mgmt/tm/sys/folder/~ocp

##
## Delete AS3 declaration
##
curl -k -u admin:admin -H "Content-Type: application/json" -X POST https://10.1.20.240/mgmt/shared/appsvcs/declare -H expect: -d '{ "class": "AS3", "declaration": { "class": "ADC", "schemaVersion": "3.1.0", "id": "f5demo", "ocp_AS3": { "class": "Tenant"   }  }  }'


# delete ARP entries
curl -k -u admin:admin -H "Content-Type: application/json" https://10.1.20.240/mgmt/tm/net/arp?options=all -X DELETE

# delete vxlan profile

curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.20.240/mgmt/tm/net/self/~Common~10.130.0.4~14
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.20.240/mgmt/tm/net/self/~Common~10.130.0.3~14
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.20.240/mgmt/tm/net/self/~Common~vxlan-float
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.20.240/mgmt/tm/net/self/~Common~vxlan-local


curl -k -u admin:admin -H "Content-Type: application/json" -X PATCH -d '{"records":{}}' https://10.1.20.240/mgmt/tm/net/fdb/tunnel/~Common~openshift_vxlan

curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.20.240/mgmt/tm/net/tunnels/tunnel/~Common~openshift_vxlan
curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.20.240/mgmt/tm/net/tunnels/vxlan/~Common~ose-vxlan

sleep 3
curl -k -u admin:admin -H "Content-Type: application/json" -d '{"command":"save"}' https://10.1.20.240/mgmt/tm/sys/config

#
# Delete bigip node 
oc delete -f host.yaml

printf "##############################################\n"
printf "Connect to Frontend APP with http://10.1.10.80\n"
printf "##############################################\n\n\n"

printf "##############################################\n"
printf "Using command: kubectl get pods --all-namespaces to check containers status\n"
printf "Make sure that everything is up and running\n"
printf "Wait for all containers related to the demo to be in running mode\n"
printf "##############################################\n\n\n"
#oc get pods --all-namespaces
