NGINX Ingress Controller for OpenShift
======================================

Introduction
~~~~~~~~~~~~

NGINX Ingress Controller has been configured in the namespace "nginx-ingress".

There is an example of using an Ingress resource.

NGINX is using the BIG-IP as the edge load balancer.

NGINX is also using "proxy protocol" to preserve the source IP address of the connection.

This can be seen when connecting to https://blue.ingress.dc1.example.com

The resource is using a certificate that is loaded on NGINX, but NGINX is able to insert the 
proper XFF because the BIG-IP is providing the original client IP address via proxy protocol.