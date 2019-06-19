.. _container-connector: 

Overview of F5® Container Connector (CC)
========================================

Overview
--------

The  Container Connector makes L4-L7 services available to users deploying microservices-based applications in a containerized infrastructure. The CC - Kubernetes allows you to expose a Kubernetes Service outside the cluster as a virtual server on a BIG-IP® device entirely through the Kubernetes API.

The offical F5 documentation is here: `F5 Kubernetes Container Integration <http://clouddocs.f5.com/containers/v1/kubernetes/>`_

Architecture
------------

The Container Connector for Kubernetes comprises the *f5-k8s-controller* and user-defined “F5 resources”. The *f5-k8s-controller* is a Docker container that can run in a *Kubernetes Pod*. The “F5 resources” are *Kubernetes ConfigMap* resources that pass encoded data to the f5-k8s-controller. These resources tell the f5-k8s-controller: 

* What objects to configure on your BIG-IP

* What *Kubernetes Service* the BIG-IP objects belong to (the frontend and backend properties in the *ConfigMap*, respectively).

The f5-k8s-controller watches for the creation and modification of F5 resources in Kubernetes. When it discovers changes, it modifies the BIG-IP accordingly. For example, for an F5 virtualServer resource, the CC - Kubernetes does the following:

* creates objects to represent the virtual server on the BIG-IP in the specified partition;
* creates pool members for each node in the Kubernetes cluster, using the NodePort assigned to the service port by Kubernetes; 
* monitors the F5 resources and linked Kubernetes resources for changes and reconfigures the BIG-IP accordingly.
* the BIG-IP then handles traffic for the Service on the specified virtual address and load-balances to all nodes in the cluster. 
* within the cluster, the allocated NodePort is load-balanced to all pods for the Service.

Before being able to use the Container Connecter, you need to handle some prerequisites

Prerequisites
-------------

* You must have a fully active/licensed BIG-IP
* A BIG-IP partition needs to be setup for the Container connector.
* You need a user with administrative access to this partition
* Your kubernetes environment must be up and running already 
