Lab 3.3 - Deploy Better L7 WAF Policies
=======================================

This lab will deploy L7 WAF policies to protect NGINX+ and the applications
that are running behind it.

In the previous lab the BIG-IP was acting as a L4 TCP proxy similar to a cloud
proxy like an AWS NLB, Azure ALB, or Google Regional TCP Load Balancer.

The BIG-IP is capable of providing advanced DDoS and  Web
Application Firewall (WAF) protection.

Deploying a WAF Policy
----------------------

On the K8S Master Node run the specified ``kubectl`` command.

This will update the ConfigMap and trigger the F5 BIG-IP Controller for 
Kubernetes to push a new updated configuration to the BIG-IP that is sitting
outside the Kubernetes cluster.

.. code:: shell

   kubectl apply -f ~/f5-cis/cis-better-together-configmap.yaml
..

Now you should be able to trigger the WAF policy by sending a contrived attack
to steal coffee.

.. code:: shell
  
   curl -k https://cafe.example.com/coffee -v -H "X-Hacker: cat /etc/paswd"
  
On the BIG-IP go to Security -> Event Logs and you should see the blocked request.

.. image:: /_static/class1-module3-lab2-view-illegal-request.png
