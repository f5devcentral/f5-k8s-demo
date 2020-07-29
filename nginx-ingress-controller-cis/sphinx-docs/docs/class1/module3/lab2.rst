Deploy L4 TCP LB for NGINX+
----------------------------

This lab will deploy basic L4 TCP services for NGINX+.

About Application Services 3 (AS3)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Container Ingress Services makes use of AS3 for configuring the BIG-IP.
This provides a declarative interface to deploying basic and advanced
L4-L7 services.

A Basic L4 Services
~~~~~~~~~~~~~~~~~~~

First we will deploy a rudimentary L4 TCP reverse proxy to NGINX+ from
the BIG-IP.  This configuration is in the form of a JSON file that is 
stored in a Kubernetes ConfigMap (a common pattern for storing external
configuration files in Kubernetes).

The contents of our first example:

.. code:: JavaScript
  
  ---
  # Source: F5Demo/templates/configmap.yaml
  kind: ConfigMap
  apiVersion: v1
  metadata:
    name: nginx-plus-as3-configmap
    labels:
      f5type: virtual-server
      as3: "true"
  data:
    template: |
      {
        "class": "AS3",
        "declaration": {
          "class": "ADC",
          "schemaVersion": "3.1.0",
          "id": "nginx-plus",
          "label": "CIS AS3 Example",
          "remark": "Example of using CIS",
          "AS3": {
            "class": "Tenant",
            "MyApps": {
               "class": "Application",
               "template": "generic",
               "ingress": {
                  "class": "Service_TCP",
                  "virtualAddresses": ["10.1.10.10"],
                 "remark":"ingress: f5demo.tcp.v1",

                 "virtualPort": 80,
                  "pool": "ingress_pool"
               },
               "ingress_pool": {
                  "class": "Pool",
                  "monitors": [ "tcp" ],
                  "members": [{
                     "servicePort": 80,
                     "serverAddresses": []
                  }]
               },
               "ingresstls": {
                  "class": "Service_TCP",
                  "virtualAddresses": ["10.1.10.10"],
                 "remark":"ingresstls: f5demo.tcp.v1",

                 "virtualPort": 443,
                  "pool": "ingresstls_pool"
               },
               "ingresstls_pool": {
                  "class": "Pool",
                  "monitors": [ "tcp" ],
                  "members": [{
                     "servicePort": 80,
                     "serverAddresses": []
                  }]
               }
         }
         }
      }
      }

The file is verbose, but it is a representation of the desired intent of the
BIG-IP.  It is possible to templatize these ConfigMaps using tools like Helm.
A related F5 DevCentral `Article <https://devcentral.f5.com/articles/templating-enhanced-kubernetes-load-balancing-with-a-helm-operator-34279>`_ that covers this topic.

Create the ConfigMap for the basic service by applying the following command.

.. code:: shell
  
  $ kubectl apply -f ~/f5-cis/cis-configmap.yaml
  
Verify the Service
~~~~~~~~~~~~~~~~~~~

You can verify that the service is available by running the following ``curl``
command.

You can verify the service by using curl against the BIG-IP virtual server (cafe.example.com or 10.1.10.10).

.. code:: shell
  
  $  curl https://cafe.example.com/coffee -k
..

Example Output:

.. code:: shell

  ubuntu@kmaster:~/f5-cis$ curl --resolve cafe.example.com:443:10.1.10.10 https://cafe.example.com/coffee -k
  Server address: 10.244.2.96:80
  Server name: coffee-bbd45c6-b4rvc
  Date: 10/May/2019:19:15:35 +0000
  URI: /coffee
  Request ID: 626fe1f0e2067d602971af1529c884f0
  
Inspect BIG-IP Configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Back on the BIG-IP GUI verify that the AS3 declaration has been deployed.

First select the **AS3** partition.

.. image:: /_static/class1-module3-lab1-select-as3-partition.png

Browse to the "Virtual Server List" under the "Local Traffic" menu.

.. image:: /_static/newvs.png
   :width: 400pt

Also take a look at the pool.  Observe that the BIG-IP is sending traffic 
directly to NGINX+ over the CNI overlay (Flannel VXLAN).

.. image:: /_static/pools.png
   :width: 400pt

.. NOTE:: In the lab environment we pre-configured the BIG-IP for Flannel VXLAN

In the next lab exercise we will configure a WAF policy.