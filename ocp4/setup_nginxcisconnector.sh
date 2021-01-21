#!/bin/bash
oc delete -f f5-server.yaml
oc create -f f5-server-nginx-helm-template.yaml
oc delete -f nginx-ingress-controller.yaml
oc create -f nginx-ingress-cis.yaml
oc create -f nginx-cis-connector.yaml
source ~/venv/bin/activate
python ~/as3-client.py -a delete -t  ConfigMap
sleep 30
python ~/as3-client.py -a delete -t  ConfigMapNginx
