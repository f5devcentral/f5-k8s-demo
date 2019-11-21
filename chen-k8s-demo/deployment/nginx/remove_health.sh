#!/bin/bash
kubectl delete cm -n nginx-ingress healthprobe.conf 
kubectl delete cm nginx-health -n nginx-ingress
kubectl apply -f nginx-ingress.yaml
kubectl apply -f ingress-nginx-dashboard-service.yaml 
