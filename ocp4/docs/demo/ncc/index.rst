NGINX CIS Connector (NCC)
=========================

Introduction
~~~~~~~~~~~~

The following is a preview of NGINX CIS Connector(NCC).

Please note this is currently pre-release software.


Demo
~~~~

To deploy NCC go onto the web host and run the following command.

.. code-block:: shell

  $ cd ~/f5-k8s-demo/ocp4
  $ ./setup_nginxcisconnector.sh

This script will uninstall the CIS/NGINX controllers and redeploy
them using a helm template.

Once this completes you should be able to see new resources on the
BIG-IP.

You should also be able to access the previous resource that was
configured using ConfigMap and AS3:

.. code-block:: shell
  		
  $ curl https://blue.ingress.dc1.example.com/txt
  ================================================
   ___ ___   ___                    _
  | __| __| |   \ ___ _ __  ___    /_\  _ __ _ __
  | _||__ \ | |) / -_) '  \/ _ \  / _ \| '_ \ '_ \
  |_| |___/ |___/\___|_|_|_\___/ /_/ \_\ .__/ .__/
					|_|  |_|
  ================================================

	Node Name: Node Blue (No SSL)
       Short Name: node-blue-77977dfb94-4jqmb

	Server IP: 10.131.0.10
      Server Port: 8080

	Client IP: 10.131.0.112
      Client Port: 60278

  Client Protocol: HTTP
   Request Method: GET
      Request URI: /txt

      host_header: blue.ingress.dc1.example.com
       user-agent: curl/7.61.1
  x-forwarded-for: 10.1.1.4


In this example we only used a single resource to map
BIG-IP to NGINX resources.

.. code-block::
  
  apiVersion: "cis.f5.com/v1"
  kind: NginxCisConnector
  metadata:
    name: nginx-ingress
    namespace: nginx-ingress
  spec:
    virtualServerAddress: "10.1.10.102"
    iRules:
    - /Common/Proxy_Protocol_iRule
    selector:
      matchLabels:
	app: nginx-ingress-cis

In this example we specified the Virtual IP Address that
is used on the BIG-IP "10.1.10.102".  We also reference
an iRule that will perform Proxy Protocol.  Finally we
reference the name of the target Service that is being
used by the NGINX Ingress Controller.

Here is the Helm chart values used to deploy CIS:

.. code-block:: yaml

  args:
    nginx-cis-connect-mode: true
    agent: as3
    route_vserver_addr: 10.1.10.100
    bigip_partition: ocp
    openshift_sdn_name: /Common/openshift_vxlan
    bigip_url:    10.1.20.240
    insecure: true
    pool-member-type: cluster
    share-nodes: true
  bigip_login_secret: bigip-login
  image:
    pullPolicy: IfNotPresent
    repo: k8s-bigip-ctlr
    user: f5networks
  namespace: kube-system
  rbac:
    create: true
  resources: {}
  serviceAccount:
    create: true
    name: bigip-ctlr
  version:  2.2.1

and the Helm chart values for NGINX Ingress Controller

.. code-block:: yaml

  controller:
    nginxplus: true
    appprotect:
      enable: true
    image:
      repository: registry.dc1.example.com/nginx-plus-ingress
      tag: "edge"
    config:
      entries:
	proxy-protocol: "True"
	real-ip-header: "proxy_protocol"
	set-real-ip-from: "0.0.0.0/0"
    reportIngressStatus:
      nginxCisConnector: nginx-ingress
    service:
      type: ClusterIP
      externalTrafficPolicy: Cluster
      extraLabels:
	app: nginx-ingress-cis   
