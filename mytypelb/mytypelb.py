#!/usr/bin/env python
#
# MyTypeLB
##########
#
# The following is a simple PoC of using type:LoadBalancer with
# Container Ingress Services 2.0.0
#
# The process is to assign a service that includes "loadBalancerIP"
#
# This script will identify these resources and create a BIG-IP
# VirtaulServer with the IP address specified.
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
# -Only uses a single port from the service (workaround: create multiple services with same loadBalancerIP
# -hardcodes "default" namespace and name of configmap
#
#
from kubernetes import client, config
import json
# Configs can be set in Configuration class directly or using helper utility
config.load_kube_config()

v1 = client.CoreV1Api()
#print("Listing pods with their IPs:")
#ret = v1.list_pod_for_all_namespaces(watch=False)
ret = v1.list_service_for_all_namespaces(watch=False)
configmap = {}
# hardcoded values
namespace = "default"
configmap_name = 'as3-configmap-mytypelb'
for i in ret.items:
    # only look for type LoadBalancer
    if i.spec.type != "LoadBalancer":
        continue

    # only inspect services that specify a load balancer IP
    if i.spec.load_balancer_ip:
        # add status
        i.status.load_balancer.ingress = [{'ip':i.spec.load_balancer_ip}]
        # add labels that will be used by AS3
        
        i.metadata.labels['cis.f5.com/as3-tenant'] = 'MyTypeLB'
        i.metadata.labels['cis.f5.com/as3-app'] = "Services"
        i.metadata.labels['cis.f5.com/as3-pool'] = "%s_%s_pool" %(i.metadata.namespace,i.metadata.name)
        servicePort = i.spec.ports[0].port
        configmap["%s_%s" %(i.metadata.namespace,i.metadata.name)] = (i.spec.load_balancer_ip, servicePort)
        # update service with labels and status
        v1.replace_namespaced_service_status(i.metadata.name,i.metadata.namespace,i)

# AS3 declaration that will be used
TEMPLATE = """    {
      "class": "AS3",
      "declaration": {
        "class": "ADC",
        "schemaVersion": "3.18.0",
        "id": "mytypelb",
        "label": "PoC of using type LoadBalancer with CIS 2.0.0",
        "remark": "PoC of using type LoadBalancer with CIS 2.0.0",
          "MyTypeLB": {
            "class": "Tenant",
             "Services": {
               "class":"Application",
               "template": "generic"
               }
           }
       }}"""
d = json.loads(TEMPLATE)

for app, dest in configmap.items():
    # AS3 definition of TCP service
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

# loop through existing configmaps
ret = v1.list_namespaced_config_map(namespace, watch=False)
exists = False
for i in ret.items:
    if i.metadata.name == configmap_name:
        exists = True
        # update if one exists
        v1.replace_namespaced_config_map(configmap_name, namespace, {'metadata':{'name':'as3-configmap-mytypelb',
                                            'labels': {'f5type':'virtual-server','as3':'true'}},
                                             'data':{'template':json.dumps(d,indent=2)}})        
if not exists:
    # create new configmap if none exists
    v1.create_namespaced_config_map(namespace, {'metadata':{'name':'as3-configmap-mytypelb',
                                            'labels': {'f5type':'virtual-server','as3':'true'}},
                                             'data':{'template':json.dumps(d,indent=2)}})
