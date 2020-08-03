NGINX Ingress Controller for OpenShift
======================================

Introduction
~~~~~~~~~~~~

NGINX Ingress Controller has been configured in the namespace "nginx-ingress".

Note that you need to complete the "ConfigMap" step of setting `as3: "true"` to
complete this part of the demo.

There is an example of using an Ingress resource.

NGINX is using the BIG-IP as the edge load balancer.

NGINX is also using "proxy protocol" to preserve the source IP address of the connection.

Demo
~~~~

Start by changing the "Project" to "nginx-ingress" in the OpenShift Console and click on "Ingresses"
under "Networking".

.. image:: ocp4-console-ingresses.png
  :scale: 50 %

If you click on the blue-ingress example you can click on YAML to see what the Ingress resource looks like.

.. code-block:: YAML

    spec:
    tls:
        - hosts:
            - blue.ingress.dc1.example.com
        secretName: tls-secret
    rules:
        - host: blue.ingress.dc1.example.com
        http:
            paths:
            - backend:
                serviceName: node-blue
                servicePort: 80

In this example NGINX is performing TLS termination of the connection and SSL offload.

Next click on ConfigMaps under Workloads.  Find the "my-nginx-ingress-controller" resource.

.. code-block:: YAML

    data:
    proxy-protocol: 'True'
    real-ip-header: proxy_protocol
    set-real-ip-from: 10.130.0.0/23

Note that NGINX is configured to use "proxy_protocol".  This enables a TCP connection to embed the original Client
IP address at the beginning of a connection (without the need to use X-Forwarded-For or a mechanism that requires L7 
visibility).

In this example we are enabling "proxy_protocol" for connections from the BIG-IP.  In the previous ConfigMaps section
you may have noticed that an iRule is being used to insert the "proxy_protocol" information.

.. code-block:: TCL

    when CLIENT_ACCEPTED {
        set proxyheader "PROXY TCP[IP::version] [IP::remote_addr] [IP::local_addr] [TCP::remote_port] [TCP::local_port]\r\n"
    }
    
    when SERVER_CONNECTED {
        TCP::respond $proxyheader
    }

This can be seen when connecting to https://blue.ingress.dc1.example.com

Take note that the original client IP address is visible despite the BIG-IP only performing TCP
load balancing to the NGINX Ingress Controller.

.. image:: chrome-blue-ingress.png
  :scale: 50%

The resource is using a certificate that is loaded on NGINX, but NGINX is able to insert the 
proper XFF because the BIG-IP is providing the original client IP address via proxy protocol.