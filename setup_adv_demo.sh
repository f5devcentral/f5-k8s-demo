#!/bin/sh
kubectl create -f my-website-deployment.yaml
kubectl create -f my-website-service.yaml
kubectl create -f my-website-configmap.yaml
./annotate-my-website.sh

kubectl create -f app1-deployment.yaml
kubectl create -f app1-service.yaml
kubectl create -f app1-configmap-bad.yaml

python custom_automation.py  --host 10.1.10.60



