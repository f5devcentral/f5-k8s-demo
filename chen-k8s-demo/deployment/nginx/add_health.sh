#!/bin/bash
kubectl create configmap  nginx-health -n nginx-ingress --from-file=nginx_health.js
kubectl create configmap  healthprobe.conf -n nginx-ingress --from-file=healthprobe.conf
kubectl apply -f nginx-ingress.health.yaml
kubectl apply -f ingress-nginx-health-service.yaml
