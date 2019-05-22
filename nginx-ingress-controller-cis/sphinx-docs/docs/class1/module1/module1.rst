Module - Deploying and Exposing a Kubernetes Service using NodePort
=====================================================================

In this module you will learn how to deploy and expose an application
service in Kubernetes.

Kubernetes normally makes use of a private overlay network and uses a
Container Network Interface (CNI) that abstracts the technology that 
is being used (i.e. VXLAN with the CNI Flannel or BGP with the CNI Calico).

To access a container (also referred to as a "pod") you either need to
participate in the overlay network and/or make use of two methods of exposing
services.

**Method 1: Node Port**

This method exposes an ephemeral port (i.e. 31345) and maps it to a service via
a host-based load balancer, kube-proxy.  Typically kube-proxy will either use
IP Tables or IPVS to route traffic to the final destination.

**Method 2: Load Balancer**

The second method is to use an external load balancer that will either make use 
of Node Port to connect to a service or route directly to the pod via the CNI 
(participates in the VXLAN, BGP, or cloud provider network).

.. image:: /_static/k8network.png
   :width: 200pt

.. toctree::
   :maxdepth: 1
   :glob:

   lab*