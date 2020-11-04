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
from ipaddress import ip_network
# Configs can be set in Configuration class directly or using helper utility
config.load_kube_config()

v1 = client.CoreV1Api()
api = client.CustomObjectsApi()
#print("Listing pods with their IPs:")
#ret = v1.list_pod_for_all_namespaces(watch=False)

crdmap = {}
# hardcoded values
namespace = "default"

# base config
#
# This is a very simple local IPAM known as "chenpam"
#
# It relies on a ConfigMap that contains a list of IP ranges
# the LoadBalancerIP will be picked either from one provided by
# the end-user or from the list
#
base_configmap = 'default/chenpam'
(base_configmap_namespace,base_configmap_name) = base_configmap.split('/')
ret = v1.read_namespaced_config_map(base_configmap_name, base_configmap_namespace)

base_config = {'ranges':['10.1.10.0/24'],
               'allocated':[],
               'conflict':[],}
base_config = json.loads(ret.data['config'])
my_configmap = ret

all_ips = []
for range in base_config['ranges']:
    all_ips.extend([str(a) for a in ip_network(range).hosts()])

next_idx = all_ips.index(base_config['next'])

# grab all services

ret = v1.list_service_for_all_namespaces(watch=False)

for i in ret.items:
    # only look for type LoadBalancer
    if i.spec.type != "LoadBalancer":
        continue
    print(i.status.load_balancer.ingress)
    if i.status.load_balancer.ingress:
        ip_addr = i.status.load_balancer.ingress[0].ip
    # only inspect services that specify a load balancer IP
    elif i.spec.load_balancer_ip:
        ip_addr = i.spec.load_balancer_ip
    else:
        ip_addr = all_ips[next_idx]
        next_idx+=1
        base_config['allocated'].append(ip_addr)
    # add to list

    # add status
    i.status.load_balancer.ingress = [{'ip':ip_addr,'hostname':"%s.%s.dc1.example.com" %(i.metadata.name,i.metadata.namespace)}]
    # add labels that will be used by AS3

    servicePorts = [(p.port,p.target_port) for p in  i.spec.ports]
    crdmap["%s_%s" %(i.metadata.namespace,i.metadata.name)] = (ip_addr, servicePorts, i.metadata.name, i.metadata.namespace)
    # update service with labels and status
    v1.replace_namespaced_service_status(i.metadata.name,i.metadata.namespace,i)


crd_output = {}
for app, dest in crdmap.items():
    # AS3 definition of TCP service

    for port in dest[1]:
        d2 = {'apiVersion': 'cis.f5.com/v1',
         'kind': 'TransportServer',
         'metadata': {'labels': {'f5cr': 'true','chenpam':'true'},
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

group = 'cis.f5.com'
version = 'v1'
#ret = api.list_namespaced_custom_object(group, version, namespace, 'transportservers', watch=False)
ret = api.list_cluster_custom_object(group, version, 'transportservers', watch=False)

existing_crds = {}
for i in ret['items']:

    crd_name = "%s_%s" %(i['metadata']['namespace'],i['metadata']['name'])
    existing_crds[crd_name] = i
for k,v in crd_output.items():
    crd_namespace = v['metadata']['namespace']
    if k in existing_crds:
        existing_v = existing_crds[k]
        if 'labels' not in existing_v['metadata'] or 'chenpam' not in existing_v['metadata']['labels'] or existing_v['metadata']['labels']['chenpam'] != 'true':
            continue
        for i in v['spec']:
            existing_v['spec'][i] = v['spec'][i]
        print('updating',k)
        api.replace_namespaced_custom_object(group, version, crd_namespace, 'transportservers', crd_output[k]['metadata']['name'], existing_v)
    else:
        print('creating',k,crd_output[k])
        api.create_namespaced_custom_object(group, version, crd_namespace, 'transportservers', crd_output[k])

# update config
new_next = all_ips[next_idx]
print(new_next)
base_config['next'] = new_next
my_configmap.data['config'] = json.dumps(base_config)
v1.replace_namespaced_config_map(base_configmap_name, base_configmap_namespace, my_configmap)
