#!/usr/bin/env python
#
# MyTypeLB
##########
#
# The following is a simple PoC of using type:LoadBalancer with
# Container Ingress Services 2.2.0 using CRD
#
# The process is to assign a service that includes "loadBalancerIP"
#
# This script will identify these resources and create a BIG-IP
# VirtuallServer with the IP address specified.
#
# This is done by creating "TransportServer" entries to match each
# service/port.
#
# Running the Script
####################
#
# This script assumes that you have a kubeconfig file with
# appropriate privileges.
#
# Known issues
###############
#
# -hardcodes "default" namespace and name of configmap
#
#
from kubernetes import client, config
import json
import sys
# Configs can be set in Configuration class directly or using helper utility
config.load_kube_config()

v1 = client.CoreV1Api()
api = client.CustomObjectsApi()
#print("Listing pods with their IPs:")
#ret = v1.list_pod_for_all_namespaces(watch=False)
ret = v1.list_service_for_all_namespaces(watch=False)
crdmap = {}
# hardcoded values
namespace = "default"

for i in ret.items:
    # only look for type LoadBalancer
    if i.spec.type != "LoadBalancer":
        continue

    # only inspect services that specify a load balancer IP
    if i.spec.load_balancer_ip:
        # add status
        i.status.load_balancer.ingress = [{'ip':i.spec.load_balancer_ip}]
        # add labels that will be used by AS3

        servicePorts = [(p.port,p.target_port) for p in  i.spec.ports]
        crdmap["%s_%s" %(i.metadata.namespace,i.metadata.name)] = (i.spec.load_balancer_ip, servicePorts, i.metadata.name, i.metadata.namespace)
        # update service with labels and status
        v1.replace_namespaced_service_status(i.metadata.name,i.metadata.namespace,i)

crd_output = {}

for app, dest in crdmap.items():
    # AS3 definition of TCP service

    for port in dest[1]:
        d2 = {'apiVersion': 'cis.f5.com/v1',
         'kind': 'TransportServer',
         'metadata': {'labels': {'f5cr': 'true'},
                      'name': "%s-%d" %(dest[2],port[0]),
                      'namespace': dest[3]
         },
         'spec': {'mode': 'standard',
                  'pool': {'monitor': {'interval': 10, 'timeout': 10, 'type': 'tcp'},
                           'service': dest[2],
                           'servicePort': port[1]},
                  'snat': 'auto',
                  'virtualServerAddress': dest[0],
                  'virtualServerPort': port[0]}}

        crd_output["%s_%s-%s" %(dest[3],dest[2],port[0])] = d2

    continue
    d2 = {app:{'class':'Service_TCP',
          'virtualAddresses':[dest[0]],
          'virtualPort':dest[1],
          'pool':"%s_pool" %(app)},
     "%s_pool" %(app): {'class':'Pool',
                        'monitors': [ 'tcp' ],
                        'members': [{'servicePort': 80, 'serverAddresses': []}]
                        }
    }

    d['declaration']['MyTypeLB']['Services'][app] = d2[app]
    d['declaration']['MyTypeLB']['Services']["%s_pool" %(app)] = d2["%s_pool" %(app)]
group = 'cis.f5.com'
version = 'v1'
ret = api.list_namespaced_custom_object(group, version, namespace, 'transportservers', watch=False)

existing_crds = {}
for i in ret['items']:

    crd_name = "%s_%s" %(i['metadata']['namespace'],i['metadata']['name'])

    existing_crds[crd_name] = i
for k,v in crd_output.items():

    if k in existing_crds:
        existing_v = existing_crds[k]

        for i in v['spec']:
            existing_v['spec'][i] = v['spec'][i]

        api.replace_namespaced_custom_object(group, version, namespace, 'transportservers', crd_output[k]['metadata']['name'], existing_v)
    else:
        api.create_namespaced_custom_object(group, version, namespace, 'transportservers', crd_output[k])
