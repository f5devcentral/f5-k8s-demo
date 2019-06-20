Automated Deployment
====================

The following describes how to use an automated script (bash) that will deploy

 * Frontend Application
 * Backend Application (not used)
 * Website Application
 * F5 BIG-IP Controller for Kubernetes
 * NGINX Ingress Controller from NGINX, Inc (F5)

 On the BIG-IP the script will also

 * Create `kubernetes` partition
 * Create VXLAN configuration (for Flannel)

Running the script
------------------

To run the script go into the `~/f5-demo` directory on `node1`

.. code-block:: sh

  $ cd ~/f5-demo/chen-k8s-demo/deployments

Then run the script `setup_demo.sh`

.. code-block:: sh

  $ ./setup_demo.sh

Basic Deployment
----------------

To do a basic deployment run the following command.

.. code-block:: sh

  $ kubectl apply -f as3-configmap-basic.yaml

This will deploy a simple TCP service for the "frontend" service and HTTP service
for the "website" service.

Verify Basic Deployment
~~~~~~~~~~~~~~~~~~~~~~~

You can verify the TCP service by running the following curl command.

.. code-block:: sh

  $ curl 10.1.10.81/txt
  ================================================
   ___ ___   ___                    _
  | __| __| |   \ ___ _ __  ___    /_\  _ __ _ __
  | _||__ \ | |) / -_) '  \/ _ \  / _ \| '_ \ '_ \
  |_| |___/ |___/\___|_|_|_\___/ /_/ \_\ .__/ .__/
                                        |_|  |_|
  ================================================

        Node Name: F5 Docker vLab
       Short Name: my-frontend-685d7db7d8-mflfz

        Server IP: 10.233.64.32
      Server Port: 80

        Client IP: 10.233.125.15
      Client Port: 47224

  Client Protocol: HTTP
   Request Method: GET
      Request URI: /txt

      host_header: 10.1.10.81
       user-agent: curl/7.58.0

Observe that the Client IP is the self-ip of the BIG-IP on the VXLAN tunnel.

Next check the HTTP service

.. code-block:: sh

  $ curl 10.1.10.80/txt
  ================================================
   ___ ___   ___                    _
  | __| __| |   \ ___ _ __  ___    /_\  _ __ _ __
  | _||__ \ | |) / -_) '  \/ _ \  / _ \| '_ \ '_ \
  |_| |___/ |___/\___|_|_|_\___/ /_/ \_\ .__/ .__/
                                       |_|  |_|
  ================================================

        Node Name: WWW Kubernetes
       Short Name: my-website-75d9c6b85-fjvmv

        Server IP: 10.233.64.33
      Server Port: 80

        Client IP: 10.233.125.15
      Client Port: 51920

  Client Protocol: HTTP
   Request Method: GET
      Request URI: /txt

      host_header: 10.1.10.80
       user-agent: curl/7.58.0
  x-forwarded-for: 10.1.10.11

Observe the X-Forwarded-For header that was added by the HTTP profile.

Enhanced Demo
-------------

In the previous example we had a TCP and HTTP service.

The following example layers on the use of a NGINX Ingress Controller that is
configured to use proxy-protocol, BIG-IP ASM for WAF protection, and BIG-IP
DNS for GSLB.

Run the following command

.. code-block:: sh

  $ kubectl apply -f as3-configmap-enhanced.yaml

Verifying Enhanced demo
~~~~~~~~~~~~~~~~~~~~~~~

To verify things are working

.. code-block:: sh

  $ curl --resolve blue.f5demo.com:443:10.1.10.82 https://blue.f5demo.com/txt -k -v
  * Added blue.f5demo.com:443:10.1.10.82 to DNS cache
  * Hostname blue.f5demo.com was found in DNS cache
  *   Trying 10.1.10.82...
  ...
  > GET /txt HTTP/1.1
  > Host: blue.f5demo.com
  > User-Agent: curl/7.58.0
  > Accept: */*
  >
  < HTTP/1.1 200 OK
  < Server: nginx/1.17.0
  < Date: Thu, 20 Jun 2019 15:28:39 GMT
  < Content-Type: text/plain
  < Transfer-Encoding: chunked
  < Connection: keep-alive
  <
  ================================================
   ___ ___   ___                    _
  | __| __| |   \ ___ _ __  ___    /_\  _ __ _ __
  | _||__ \ | |) / -_) '  \/ _ \  / _ \| '_ \ '_ \
  |_| |___/ |___/\___|_|_|_\___/ /_/ \_\ .__/ .__/
                                        |_|  |_|
  ================================================

        Node Name: Node Blue (No SSL)
       Short Name: node-blue-5d48bd9b79-jqb84

        Server IP: 10.233.64.34
      Server Port: 80

        Client IP: 10.233.65.29
      Client Port: 44440

  Client Protocol: HTTP
   Request Method: GET
      Request URI: /txt

      host_header: blue.f5demo.com
       user-agent: curl/7.58.0
  x-forwarded-for: 10.1.10.11

This example connection is traversing a virtual server that examines the SNI
name that is sent by the client to route the connection to the NGINX Ingress
over TCP.  It injects a "proxy-protocol" header to pass along the original client
IP address.

Verifying WAF policy
~~~~~~~~~~~~~~~~~~~~

The enhanced demo also deploys a WAF policy.  To verify:

.. code-block:: sh

  $  curl --resolve website.f5demo.com:443:10.1.10.82 https://website.f5demo.com/txt -k -v -H "X-Hacker: cat /etc/passwd"
  ...
  > GET /txt HTTP/1.1
  > Host: website.f5demo.com
  > User-Agent: curl/7.58.0
  > Accept: */*
  > X-Hacker: cat /etc/passwd
  >
  < HTTP/1.1 200 OK
  < Cache-Control: no-cache
  < Connection: close
  < Content-Type: text/html; charset=utf-8
  < Pragma: no-cache
  < Content-Length: 188
  <
  * Closing connection 0
  * TLSv1.2 (OUT), TLS alert, Client hello (1):
  <html><head><title>Request Rejected</title></head><body>The requested URL was rejected. Please consult with your administrator.<br><br>Your support ID is: 8716975781835702304</body></html>
