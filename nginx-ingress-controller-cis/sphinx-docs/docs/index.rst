Welcome to the NGINX Ingress Controller Lab
===========================================

The goal of this lab is to introduce you to NGINX+ as a Kubernetes Ingress
Controller and F5 Container Ingress Services. The BIG-IP can act as the
"front door" to the Kubernetes cluster and bring services to NGINX+ that is
running inside the cluster.

Together NGINX+ and BIG-IP will secure traffic to the Kubernetes applications.

|
|

.. image::  /_static/nginx-plus-bigip-better-together.png
   :align: center
   :scale: 65

|
|

The UDF Blueprint called **NGINX Ingress Controller Lab** will give you access
to the following infrastructure: 

==============    ==================  ==============================================
  System                Hostame                        Description
==============    ==================  ==============================================
  BIG-IP1            ip-10-1-1-4       F5 BIG-IP
  k8S Master         ip-10-1-1-9       Kubernetes Master node (where lab files are)
  k8S Node1          ip-10-1-1-10      Kubernetes Minion
  k8S Node2          ip-10-1-1-11      Kubernetes Minion
  Windows RDP        ip-10-1-1-8       Windows JumpHost
==============    ==================  ==============================================

.. note:: The entire lab can be performed from the Windows Jumphost
   (if you've not set up SSH keys for UDF).

.. note:: The Lab Guide is available from UDF or on the Windows Jumphost.

   .. image:: /_static/NISguide.png
      :scale: 50
 
.. toctree::
   :maxdepth: 2
   :glob:

   class*/class*
