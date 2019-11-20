#!/bin/bash
kubectl create configmap  nginx-to-as3 -n nginx-ingress --from-file=nginx_to_as3.js
kubectl create configmap  localhost.conf.template -n nginx-ingress --from-file=localhost.conf.template
kubectl create configmap  nginx-ingress.wrapper -n nginx-ingress --from-file=nginx-ingress.wrapper
kubectl create -f nginx-plus-ingress.ds.yaml
