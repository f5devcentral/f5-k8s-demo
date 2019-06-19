Welcome to F5 101 Kubernetes lab's documentation!
==================================================

Introduction
============

#Introduction to Kubernetes and F5 solutions for Kubernetes

The purpose of this lab is to give you more visibility on

* Overview of Kubernetes and its key components
* Install Kubernetes in different flavors: All-in-one, One kubernetes Cluster (1 Master and 2 minions), 
* How to launch application in Kubernetes
* How to install and use F5 containerized solutions (Container connector, Application Service proxy and F5 kube proxy)

We consider that you have a valid UDF access (Private Cloud of F5 Networks) to do this lab. If not, you may review the pre-requisites about our lab setup .


Contents:


.. toctree::
   :maxdepth: 2
   :caption: Getting Started

   getting-started/getting-started-intro.rst
   getting-started/getting-started-kubernetes-overview.rst
   getting-started/getting-started-kubernetes-networking.rst
   getting-started/getting-started-kubernetes-services.rst

.. toctree::
   :maxdepth: 2
   :caption: Labs setup

   labs-setup/labs-setup.rst
   labs-setup/labs-setup-access-udf.rst
   labs-setup/labs-setup-automated-deploy.rst

.. toctree::
   :maxdepth: 2
   :caption: F5 container connector

   f5-container-connector/f5-container-connector-overview.rst
   f5-container-connector/f5-container-connector-installation.rst
   f5-container-connector/f5-container-connector-usage.rst

.. toctree::
   :maxdepth: 2
   :caption: Cluster setup (For reference)

   cluster-setup-guide/cluster-setup-guide-cluster-installation.rst
   cluster-setup-guide/cluster-setup-guide-master-setup.rst
   cluster-setup-guide/cluster-setup-guide-node-setup.rst
   cluster-setup-guide/cluster-setup-guide-cluster-test.rst


