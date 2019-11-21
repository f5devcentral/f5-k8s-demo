#!/bin/bash
kubectl delete cm -n nginx-ingress localhost.conf.template
kubectl delete cm nginx-to-as3 -n nginx-ingress
kubectl delete cm -n nginx-ingress nginx-ingress.wrapper
kubectl delete -f nginx-plus-ingress.ds.yaml
