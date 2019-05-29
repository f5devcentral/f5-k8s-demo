#!/usr/bin/env bash

cd "${BASH_SOURCE%/*}"

#wget --no-verbose -O demo-magic.sh https://raw.githubusercontent.com/paxtonhare/demo-magic/master/demo-magic.sh
#chmod +x demo-magic.sh
. demo-magic.sh
TYPE_SPEED=15
DEMO_PROMPT="\u@\h:~# "
clear

#########################
#####   K8S Demo    #####
#########################

#Lab 1
printf "\033[32mDeploy an Application \033[0m\n"
TYPE_SPEED=300
pe "kubectl create -f - <<'EOF'
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: coffee
spec:
  replicas: 2
  selector:
    matchLabels:
      app: coffee
  template:
    metadata:
      labels:
        app: coffee
    spec:
      containers:
      - name: coffee
        image: nginxdemos/hello:plain-text
        ports:
        - containerPort: 80
EOF"
#TYPE_SPEED=15
pe "kubectl get po"
pe "kubectl get po -o wide"

# Curl to the pod IP.
POD=$(kubectl get pods -o=jsonpath='{.items[0].metadata.name}')
CLUSTER_IP=$(kubectl get pods -o=jsonpath='{.items[0].status.podIP}')
pe "curl ${CLUSTER_IP}"

#Lab 2
printf "\033[32mExposing an Application Service \033[0m\n"
pe "kubectl expose deployment/coffee --name coffee-svc"
pe "kubectl get svc"

pe "kubectl get po"

##Show that a DNS entry was created
pe "kubectl exec -it ${POD} -- nslookup coffee-svc"

#curl the the service/cluster address. Do this a few times.
printf "\033[32mVerify Access to Coffee \033[0m\n"
CLUSTER_IP=$(kubectl get service coffee-svc -o go-template='{{.spec.clusterIP}}')
pe "for run in {1..5}; do curl ${CLUSTER_IP}; done"

printf "\033[32mCoffee and Tea Service \033[0m\n"
pe "kubectl apply -f ~/kubernetes-ingress/examples/complete-example/cafe.yaml"

#Module 2, Lab1 -- Deploy NGINX Controller
printf "\033[32mDeploy NGINX Ingress Controller \033[0m\n"
pe "cd ~/kubernetes-ingress/deployments/"

pe "kubectl apply -f common/ns-and-sa.yaml"

pe "kubectl create secret docker-registry regcred --docker-server=registry.internal:30500 --docker-username=registry --docker-password=registry --docker-email=gsa@f5.com -n nginx-ingress"

pe "kubectl apply -f common/default-server-secret.yaml"

pe "kubectl apply -f common/nginx-config.yaml"

pe "kubectl apply -f rbac/rbac.yaml"

pe "kubectl apply -f deployment/nginx-plus-ingress.yaml"

pe "kubectl get po -n nginx-ingress"

pe "kubectl create -f service/nodeport.yaml"

pe "kubectl get svc -n nginx-ingress"

#Module 2, Lab 2 -- Deploy the "cafe" application
printf "\033[32mDeploy the Cafe Application \033[0m\n"

pe "cd ~/kubernetes-ingress/examples/complete-example/"

pe "kubectl apply -f cafe.yaml"

pe "kubectl create -f cafe-secret.yaml"

pe "kubectl create -f cafe-ingress.yaml"

###Need to determine these ports. TBD...FROM HERE
PORT=$(kubectl get service -n nginx-ingress -o jsonpath='{.items[0].spec.ports[1].nodePort}')

pe "curl --resolve cafe.example.com:${PORT}:10.1.20.20 https://cafe.example.com:${PORT}/coffee -k"

#Module 3 -- Container ingress services

##Lab 1
##Create the partition on the BIG-IP
pe "curl -k -u admin:admin -d '{\"name\": \"kubernetes\"}' -H 'Content-Type: application/json' https://10.1.1.4/mgmt/tm/auth/partition"

pe "kubectl create secret generic bigip-login --namespace kube-system --from-literal=username=admin --from-literal=password=admin"

pe "kubectl apply -f ~/f5-cis/cis-sa.yaml -n kube-system"

pe "kubectl apply -f ~/f5-cis/cis-rbac.yaml -n kube-system"

pe "kubectl apply -f ~/f5-cis/f5-cc-deployment.yaml -n kube-system"

pe "kubectl apply -f ~/f5-cis/nodeport-cis-80.yaml"
pe "kubectl apply -f ~/f5-cis/nodeport-cis-443.yaml"
pe "kubectl apply -f ~/f5-cis/nodeport-cis-8080.yaml"

##Module 3, Lab2 -- deploy CIS
pe "cat ~/f5-cis/cis-configmap.yaml"

pe "kubectl apply -f ~/f5-cis/cis-configmap.yaml"

pe "curl https://cafe.example.com/coffee -k"

##Module 3, Lab3

pe "kubectl apply -f ~/f5-cis/cis-better-together-configmap.yaml"

pe 'curl -k https://cafe.example.com/coffee -v -H "X-Hacker: cat /etc/paswd"'




