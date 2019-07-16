Automated Deployment
====================

The following describes how to use an automated script (bash) that will deploy

 * Frontend Application
 * Backend Application (not used)
 * Website Application
 * F5 BIG-IP Controller for Kubernetes
 * NGINX Ingress Controller from NGINX, Inc (F5)

 On the BIG-IP the script will also

 * Create ``kubernetes`` partition
 * Create VXLAN configuration (for Flannel)

Running the script
------------------

To run the script go into the ``~/f5-demo`` directory on ``node1``

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

.. code-block:: text

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

.. code-block:: text

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

Sorting K8s Demo
----------------

The following sets up an environment similar to the one used in the following demo: https://youtu.be/Df8FcQ6QSo8

Summary
~~~~~~~

This is a demo of TCP, HTTP, and mutual TLS.  Similar to the basic demo.

Setup
~~~~~

Run the following command

.. code-block:: sh

  $ ./setup_istio.sh

Teardown
~~~~~~~~

Run the following command

.. code-block:: sh

  $ ./teardown_istio.sh


Enhanced Demo
-------------

In the previous example we had a TCP and HTTP service.

The following example layers on the use of a NGINX Ingress Controller that is
configured to use proxy-protocol, BIG-IP ASM for WAF protection, and BIG-IP
DNS for GSLB.

It is not recommended that you do "everything" for a demo.  Instead take a look
at what is of interest from the examples below.

Run the following command

.. code-block:: sh

  $ kubectl apply -f as3-configmap-enhanced.yaml

Verifying Enhanced demo
~~~~~~~~~~~~~~~~~~~~~~~

To verify things are working

.. code-block:: text

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

Verifying DNS
~~~~~~~~~~~~~

The enhanced demo includes an example of provisioning BIG-IP DNS records.

Some example queries.

.. code-block:: sh

  # individual wide-ip
  $ dig @10.1.10.60 my-frontend.f5demo.com +short
  10.1.10.81
  # wildcard DNS, health check on Ingress
  $ dig @10.1.10.60 foobar.f5demo.com +short
  10.1.10.82
  # separate wide-ip w/ health check on service
  $ dig @10.1.10.60 blue.f5demo.com +short
  10.1.10.82

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

HTTP Routing
~~~~~~~~~~~~

The virtual 10.1.10.82 is configured with a Local Traffic Policy to direct
requests to the proper backend.

Requests to http://website.f5demo.com will go directly to the backend Pod.

.. code-block:: text

  curl --resolve website.f5demo.com:80:10.1.10.82 http://website.f5demo.com/txt -I
  HTTP/1.1 200 OK
  Date: Fri, 21 Jun 2019 10:15:02 GMT
  Server: Apache/2.4.39 (Unix) OpenSSL/1.1.1b
  ...

.. note:: You can verify by seeing the "Server" is set to Apache.

Requests to http://green.f5demo.com will go through the NGINX Ingress.

.. code-block:: text

  $ curl --resolve green.f5demo.com:80:10.1.10.82 http://green.f5demo.com/txt -I
  HTTP/1.1 200 OK
  Server: nginx/1.17.0
  Date: Fri, 21 Jun 2019 10:23:38 GMT
  Content-Type: text/plain
  Connection: keep-alive
  x-nginx-ingress: nginx-ingress-755df5c4cc-wkjxk

.. note:: observe the "x-nginx-ingress" header.  This was added as a custom
          annotation to the green ingress to show which Ingress is handling
          the connection

SNI Routing
~~~~~~~~~~~

In the HTTP routing example the BIG-IP was making a traffic decision at L7.

This example will look at the TLS option 0, Server Name Indication, to make a
traffic decision.  This can be done without the need to terminate the SSL
connection.

Previously http://green.f5demo.com went through the NGINX Ingress.  To show
the flexibility of the BIG-IP we will now sent traffic for https://green.f5demo.com
directly to the backend pod.

.. code-block:: text

  $ curl -k --resolve green.f5demo.com:443:10.1.10.82  https://green.f5demo.com/txt -I -v
  ...
  * Server certificate:
  *  subject: C=XX; L=Default City; O=Default Company Ltd
  *  start date: Nov 22 19:13:45 2017 GMT
  *  expire date: Nov 22 19:13:45 2018 GMT
  *  issuer: C=XX; L=Default City; O=Default Company Ltd
  *  SSL certificate verify result: self signed certificate (18), continuing anyway.
  * Using HTTP2, server supports multi-use
  * Connection state changed (HTTP/2 confirmed)
  * Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
  * Using Stream ID: 1 (easy handle 0x5609990de580)
  > HEAD /txt HTTP/2
  > Host: green.f5demo.com
  > User-Agent: curl/7.58.0
  > Accept: */*
  >
  * Connection state changed (MAX_CONCURRENT_STREAMS updated)!
  < HTTP/2 200
  HTTP/2 200
  < server: nginx/1.17.0
  server: nginx/1.17.0
  < date: Fri, 21 Jun 2019 10:45:27 GMT
  date: Fri, 21 Jun 2019 10:45:27 GMT
  < content-type: text/plain
  content-type: text/plain

.. note:: observe that the SSL certificate is issued by "Default Company" and
          not "F5 Demo" that will be seen later.

Next we will look at having the BIG-IP terminate the SSL connection.

.. code-block::

  curl -k --resolve website.f5demo.com:443:10.1.10.82  https://website.f5demo.com/txt -I -v
  ...
  * Server certificate:
  *  subject: CN=wildcard.f5demo.com
  *  start date: May 24 20:42:00 2018 GMT
  *  expire date: May 23 20:42:00 2023 GMT
  *  issuer: C=US; ST=Washington; L=Seattle; O=F5 Networks; OU=Demo
  *  SSL certificate verify result: unable to get local issuer certificate (20), continuing anyway.
  > HEAD /txt HTTP/1.1
  > Host: website.f5demo.com
  > User-Agent: curl/7.58.0
  > Accept: */*
  >
  < HTTP/1.1 200 OK
  HTTP/1.1 200 OK
  < Date: Fri, 21 Jun 2019 10:51:14 GMT
  Date: Fri, 21 Jun 2019 10:51:14 GMT
  < Accept-Ranges: bytes
  Accept-Ranges: bytes
  < X-COLOR: 656263
  X-COLOR: 656263
  < Content-Type: text/plain
  Content-Type: text/plain
  < Set-Cookie: BIGipServer~AS3~MyApps~websitetls_pool=742517002.47873.0000; path=/; Httponly; Secure

.. note:: observe the certificate is issued by "F5 Networks" and that there is
          a cookie that is being set by the BIG-IP for cookie persistence

Lastly we will pass the traffic to the NGINX Ingress to terminate the SSL
connection.

.. code-block:: text

  curl -k --resolve blue.f5demo.com:443:10.1.10.82  https://blue.f5demo.com/txt -I -v
  * Server certificate:
  *  subject: CN=wildcard.f5demo.com
  *  start date: May 24 20:42:00 2018 GMT
  *  expire date: May 23 20:42:00 2023 GMT
  *  issuer: C=US; ST=Washington; L=Seattle; O=F5 Networks; OU=Demo
  *  SSL certificate verify result: unable to get local issuer certificate (20), continuing anyway.
  > HEAD /txt HTTP/1.1
  > Host: blue.f5demo.com
  > User-Agent: curl/7.58.0
  > Accept: */*
  >
  < HTTP/1.1 200 OK
  HTTP/1.1 200 OK
  < Server: nginx/1.17.0
  Server: nginx/1.17.0
  < Date: Fri, 21 Jun 2019 10:54:24 GMT
  Date: Fri, 21 Jun 2019 10:54:24 GMT
  < Content-Type: text/plain
  Content-Type: text/plain
  < Connection: keep-alive
  Connection: keep-alive
  < x-nginx-ingress: nginx-ingress-755df5c4cc-wkjxk
  x-nginx-ingress: nginx-ingress-755df5c4cc-wkjxk

.. note:: observe the certificate is issued by "F5 Networks" in this case the
          certificate is stored in a Kubernetes secret and is loaded on the NGINX
          Ingress Controller.  Observe the "x-nginx-ingress" header that shows
          that the NGINX Ingress is terminating the SSL connection.

Removing the AS3 Declaration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the previous examples an AS3 declaration was deployed as a configmap.  To
delete the existing AS3 configuration you need to deploy another configmap that
has an "empty" AS3 declaration.

.. code-block:: sh

  $ kubectl apply -f as3-configmap-empty.yaml


Tearing it all down
-------------------

To reset the environment run the following (this will remove EVERYTHING).

.. code-block::

  $ ./teardown_demo.sh
