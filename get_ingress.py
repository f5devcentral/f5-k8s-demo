import pykube
import json
from bigip_dns_helper import DnsHelper

import operator
from six import iteritems
from os.path import expanduser
homedir = expanduser("~")



def get_services_policies(config_file="%s/.kube/config" %(homedir)):
    api = pykube.http.HTTPClient(pykube.config.KubeConfig.from_file(config_file))

    pods = pykube.objects.Pod.objects(api).filter(namespace="default")
    services = pykube.objects.Service.objects(api).filter(namespace="default")
    ready_pods = filter(operator.attrgetter("ready"), pods)

    endpoints = pykube.objects.Endpoint.objects(api).filter(namespace="default")
    ingresses = pykube.objects.Ingress.objects(api).filter(namespace="default")

    configmaps = pykube.objects.ConfigMap.objects(api).filter(namespace="default")
        
    my_services = {}
    my_policies = {}
    my_backends = {}
    for cm in configmaps:
        if 'labels' in cm.obj['metadata'] and 'f5type' not in  cm.obj['metadata']['labels']:
            continue
        if 'data' not in cm.obj:
            continue
        d = json.loads(cm.obj['data']['data'])
        iapp = False
        addr = None
        port = None
        custom_dns = None
        custom_translate_ip = None
        if 'iapp' in  d["virtualServer"]["frontend"]:
            iapp = True
#            print d['virtualServer']['frontend']['iappVariables']
            addr = d['virtualServer']['frontend']['iappVariables']['pool__addr']
            port = d['virtualServer']['frontend']['iappVariables']['pool__port']
        else:
            pass
#            print d['virtualServer']['frontend']
        if 'virtualAddress' in d['virtualServer']['frontend'] and 'bindAddr' in d['virtualServer']['frontend']['virtualAddress']:
            addr = d['virtualServer']['frontend']['virtualAddress']['bindAddr']
        if 'virtualAddress' in d['virtualServer']['frontend'] and 'port' in d['virtualServer']['frontend']['virtualAddress']:            
            port = d['virtualServer']['frontend']['virtualAddress']['port']
        if 'annotations' in cm.obj['metadata'] and  'virtual-server.f5.com/ip' in cm.obj['metadata']['annotations']:
            addr = cm.obj['metadata']['annotations']['virtual-server.f5.com/ip']
        if 'annotations' in cm.obj['metadata'] and  'custom_dns' in cm.obj['metadata']['annotations']:
            custom_dns = cm.obj['metadata']['annotations']['custom_dns']
        if 'annotations' in cm.obj['metadata'] and  'custom_dns' in cm.obj['metadata']['annotations']:
            custom_translate_ip = cm.obj['metadata']['annotations']['custom_translate_ip']
            
            
        my_backends[d['virtualServer']['backend']['serviceName']] = (iapp,addr,port,custom_dns,custom_translate_ip)

    #
    # Grab L7 ingress
    #
    for ing in ingresses:
    #    print ing.obj['metadata']['name']
    #    print ing.obj['spec']['backend']['serviceName']
    #    print ing.obj['spec']['backend']['servicePort']
        ing_name = ing.obj['metadata']['name']
        ing_namespace = ing.obj['metadata']['namespace']
        my_rules = []
        for rule in  ing.obj['spec']['rules']:
#            print rule
            hostname = rule['host']
            for path in rule['http']['paths']:
                if 'path' in path:
                    uri = path['path']
                else:
                    uri = '/'
                backend = path['backend']['serviceName']
                port = path['backend']['servicePort']
#                print hostname,uri, backend, port
                my_rules.append({'hostname':hostname,
                                 'uri':uri,
                                 'backend':backend,
                                 'port':port})
        my_policies[ing_name] = {'rules': my_rules, 'name':ing_name, 'namespace':ing_namespace}
        if 'annotations' in ing.obj['metadata']:
            if 'custom_ip' in ing.obj['metadata']['annotations']:
                my_policies[ing_name]['dest'] =  ing.obj['metadata']['annotations']['custom_ip']


                # foo.bar.com /foo echoheadersx 80
    #
    # Grab endpoints (internal IPs)
    #

    #for eps in endpoints:
    #    print eps.obj['metadata']['name']
    #    for pod in eps.obj['subsets']:
    #        print pod

    #
    # Grab services L4 services
    #
    for service in services:
        skip_service = False
        svc = {'pods':[]}
    #    print service
    #    print service.obj['status']
    #    print service.obj['spec']['ports']
    #    print service.__dict__

        svc['clusterIP'] = service.obj['spec']['clusterIP']
        if 'externalIPs' in service.obj['spec']:
            svc['loadbalancerIP'] = service.obj['spec']['externalIPs'][0]
        # prefer loadbalancerIP https://github.com/kubernetes/kubernetes/pull/13005
        if 'loadbalancerIP' in service.obj['spec']:
            svc['loadbalancerIP'] = service.obj['spec']['loadbalancerIP']
        # fallback to clusterIP
        if 'loadbalancerIP' not in svc:
            svc['loadbalancerIP'] = svc['clusterIP']
        # override with f5 variables
#        print service.obj['metadata']
        if 'annotations' in service.obj['metadata']:
            if 'f5.destination' in service.obj['metadata']['annotations']:
                svc['loadbalancerIP'] =  service.obj['metadata']['annotations']['f5.destination']
            if 'kubernetes.io/ingress.class' in service.obj['metadata']['annotations']:
                if service.obj['metadata']['annotations']["kubernetes.io/ingress.class"] != 'f5.bigip':
                    skip_service = True
            for key in service.obj['metadata']['annotations']:
#                print key
                if key.startswith('f5.vs__'):
                    svc[key[3:]] = service.obj['metadata']['annotations'][key]

        if skip_service:
            continue

        svc['ports'] = service.obj['spec']['ports']
        svc['targetPort'] = service.obj['spec']['ports'][0]['targetPort']
        if 'selector' not in service.obj['spec']:
            continue
        svc['selector'] = service.obj['spec']['selector']
    #    print service.obj['spec']
        svc['name'] = service.obj['metadata']['name']
        svc['namespace'] = service.obj['metadata']['namespace']
        svc_pods = pods.filter(namespace=svc['namespace'],selector=svc['selector'])
    #    print svc_pods
        #
        # Grab pods (external IP)
        #
        for pod in svc_pods:
    #        print pod.obj['metadata']
            my_run = pod.obj['spec']['containers'][0]['name']
            my_pod = {}
            my_pod['hostIP'] =  pod.obj['status']['hostIP']
            if 'podIP' in pod.obj['status']:
                my_pod['podIP'] =  pod.obj['status']['podIP']
            svc['pods'].append(my_pod)
        my_services[svc['name']] = svc
    return (my_services,my_policies,my_backends)

if __name__ == "__main__":

    from f5.bigip import ManagementRoot
    from optparse import OptionParser
    parser = OptionParser()
    parser.add_option('-u','--user',default='admin')
    parser.add_option('-p','--password',default='admin')
    parser.add_option('--host')
    parser.add_option('--password-file',dest='password_file')
    parser.add_option('--port',default=443)
    (options,args) = parser.parse_args()

    host = options.host

    username = options.user
    

    if options.password_file:
        password = open(options.password_file).readline().strip()
    else:
        password = options.password

    (services, policies, backends) = get_services_policies()

    dns_helper = DnsHelper(host, username, password)    

    hostname_to_skip = {}
    data_group_virtual = {}
    data_group_pool = {}
    dns_records = {}
    for ing_name in policies:
        # {u'host': u'www.f5demo.com', u'http': {u'paths': [{u'backend': {u'serviceName': u'my-website', u'servicePort': 80}}]}}
        pol = policies[ing_name]
        ing_namespace = pol['namespace']
        print pol
        translate_ip = None
        for rule in pol['rules']:
            if 'dest' in pol:
                translate_ip = pol['dest']

            if rule['uri'] != '/':
                print 'skipping (can only process hostname)',rule
                hostname_to_skip[rule['hostname']] = True
                continue
            svc =  rule['backend']
            hostname = "%s" %(rule['hostname'])
            
            (iapp,addr,port,custom_dns,custom_translate_ip) = backends.get(svc,(False,None,None,None,None))
            if custom_translate_ip:
                translate_ip  = custom_translate_ip
            if iapp:
                data_group_virtual[hostname] = "/kubernetes/%s_%s.app/%s_%s_vs" %(ing_namespace,svc,ing_namespace,svc)
            else:
                data_group_pool[hostname] = "/kubernetes/%s_%s" %(ing_namespace,svc)
            if custom_dns:
                wideip = custom_dns
            else:
                wideip = "%s.f5demo.com" %(svc)
            print svc,addr,port,wideip,translate_ip
            dns_records[svc] = (addr,translate_ip,port,wideip)
    for hostname in hostname_to_skip:
        if hostname in data_group_virtual:
            del data_group_virtual[hostname]
        if hostname in data_group_pool:
            del data_group_pool[hostname]
            
    print data_group_virtual
    
    mgmt = ManagementRoot(host, username, password, port=options.port)
    records = [{'data':b,'name':a} for (a,b) in iteritems(data_group_virtual)]
    dg = mgmt.tm.ltm.data_group.internals.internal.load(name='host_to_virtual',partition='Common')
    print records
    dg.records = records
    dg.update()
    records = [{'data':b,'name':a} for (a,b) in iteritems(data_group_pool)]
    dg = mgmt.tm.ltm.data_group.internals.internal.load(name='host_to_pool',partition='Common')
    print records
    dg.records = records
    dg.update()
    for svc in backends:
        if svc in dns_records:
            print svc,dns_records[svc]
            (addr,translate_ip,port,wideip) = dns_records[svc]
        else:
            (iapp,addr,port,custom_dns,custom_translate_ip) = backends[svc]
            if custom_dns:
                wideip = custom_dns
            else:
                wideip = "%s.f5demo.com" %(svc)
            translate_ip = addr
            print svc,(addr,translate_ip,port,wideip)
        try:
            # note that that variable names are reversed.  translate_ip is addr and addr is translate_ip
            dns_helper.create_vs("bigip", "%s_vs" %(svc), "%s:%s" %(translate_ip,port), "%s:%s" %(addr,port))
            dns_helper.create_pool("%s_pool" %(svc))
            dns_helper.create_pool_members("%s_pool" %(svc),["bigip:%s_vs" %(svc)])
            dns_helper.create_wideip(wideip, ["%s_pool" %(svc)],poolLbMode='round-robin')
        except Exception,e:
            print 'failed, moving on...',e
                

        
#    print dns_records
