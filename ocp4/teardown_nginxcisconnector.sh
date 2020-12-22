#!/bin/bash
oc delete -f f5-server-nginx-helm-template.yaml
oc create -f f5-server.yaml

oc delete -f nginx-ingress-cis.yaml
oc create -f nginx-ingress-controller.yaml

oc delete -f nginx-cis-connector.yaml
source ~/venv/bin/activate
