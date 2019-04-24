#!/bin/sh
echo "disabled demo"
exit 1
python iapps/deploy_iapp_bigip.py -r --iapp_name k8s_demo --strings=pool__addr=0.0.0.0 --pool_members 192.168.1.1:80 10.1.10.60 iapps/k8s_http.json
kubectl replace -f f5-cc-deployment-cluster.yaml
kubectl apply -f f5-ingress.yaml
kubectl create -f my-website-deployment.yaml
kubectl create -f my-website-service.yaml
kubectl create -f my-website-configmap.yaml
./annotate-my-website.sh

kubectl create -f app1-deployment.yaml
kubectl create -f app1-service.yaml
kubectl create -f app1-configmap-bad.yaml
./annotate-app1.sh app1-configmap-bad.yaml

python custom_automation.py  --host 10.1.10.60



