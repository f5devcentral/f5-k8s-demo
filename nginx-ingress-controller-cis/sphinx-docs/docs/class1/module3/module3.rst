Module 3: Container Ingress Services
====================================

In this module you will deploy `Container Ingress Services`_ (CIS) to provide
basic L4 TCP Load Balancing, then make it better together with NGINX+
by applying L7 WAF policies.

Container Ingress Services will be responsible for communicating with 
the Kubernetes API to keep track of the NGINX+ Ingress service.

During this excercise you will first configure CIS to use L4 TCP Load
Balancing. Then you will configure CIS to use L7 WAF policies. These
configurations will be pushed to an F5 BIG-IP that is sitting outside the
Kubernetes cluster.

.. image::  /_static/nginx-plus-bigip-better-together.png

.. _`Container Ingress Services`: https://github.com/F5Networks/k8s-bigip-ctlr

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
