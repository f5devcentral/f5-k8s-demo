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

  $ cd ~/f5-demo/chen-k8s-demo/deployment

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

AWAF Deployment
---------------

To do a WAF deployment run the following command.

.. code-block:: sh

  $ kubectl apply -f as3-configmap-waf.yaml

This will apply a WAF policy to the previous basic example.

Verify WAF Deployment
~~~~~~~~~~~~~~~~~~~~~~~

Check the HTTP service

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

Observe the connection is successful

Now send an "attack"

.. code-block:: text

  $ curl 10.1.10.80/txt -H "x-hacker: cat /etc/passwd"
  <html><head><title>Request Rejected</title></head><body>The requested URL was rejected. Please consult with your administrator.<br><br>Your support ID is: 9673523032253005844</body></html>

You can now check the ASM logs to see more details about the attack.

NGINX App Protect Demo
----------------------

In the previous example we had a TCP and HTTP service.

The following example layers on the use of a NGINX Ingress Controller that is
configured to use proxy-protocol and NGINX App Protect for WAF protection.

Run the following command.

.. code-block:: sh

  $ kubectl apply -f as3-configmap-nginx.yaml

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

This example connection is traversing a TCP virtual server that routes the connection
to the NGINX Ingress.  It injects a "proxy-protocol" header to pass along the original client
IP address.

You can also verify that NGINX App Protect is running by sending the following curl command
from the web host.

.. code-block:: shell
  
  $ curl --resolve blue.f5demo.com:443:10.1.10.82 https://blue.f5demo.com/txt -k -H "X-Hacker: cat /etc/passwd"
  
You can tail /var/log/appprotect.log on the node1 host to see the syslog output from NAP.

.. code-block:: shell
  
  $ tail /var/log/appprotect.log
  ...
    Oct  8 13:59:32 my-release-nginx-ingress-84d6d547cb-qbhlk ASM: attack_type="Non-browser Client,Predictable Resource Location,Command Execution",blocking_exception_reason="N/A"\
    ,date_time="2020-10-08 13:59:32",dest_port="443",ip_client="10.1.10.11",is_truncated="false",method="GET",policy_name="basic-block",protocol="HTTPS",request_status="blocked",res\
    ponse_code="0",severity="Critical",sig_cves="N/A",sig_ids="200003898,200003910",sig_names="""cat"" execution attempt (2) (Header),""/etc/passwd"" access (Header)",sig_set_names=\
    "{Command Execution Signatures;OS Command Injection Signatures},{Predictable Resource Location Signatures}",src_port="43390",sub_violations="N/A",support_id="2298481500605678128\
    ",threat_campaign_names="N/A",unit_hostname="N/A",uri="/txt",violation_rating="4",vs_name="13-blue.f5demo.com:8-/",x_forwarded_for_header_value="N/A",outcome="REJECTED",outcome_\
    reason="SECURITY_WAF_VIOLATION",violations="Attack signature detected,Violation Rating Threat detected",violation_details="<?xml version='1.0' encoding='UTF-8'?><BAD_MSG><violat\
    ion_masks><block>10000000000c00-3030cc0000000</block><alarm>477f0ed09200fa8-8003434cc0000000</alarm><learn>0-0</learn><staging>0-0</staging></violation_masks><request-violations\
    ><violation><viol_index>42</viol_index><viol_name>VIOL_ATTACK_SIGNATURE</viol_name><context>header</context><header><header_name>eC1oYWNrZXI=</header_name><header_value>Y2F0IC9l\
   dGMvcGFzc3dk</header_value><header_pattern>*</header_pattern><staging>0</staging></header><staging>0</staging><sig_data><sig_id>200003898</sig_id><blocking_mask>2</blocking_mask\
   ><kw_data><buffer>LjU4LjANCkFjY2VwdDogKi8qDQp4LWhhY2tlcjogY2F0IC9ldGMvcGFzc3dkDQoNCg==</buffer><offset>28</offset><length>8</length></kw_data></sig_data><sig_data><sig_id>200003\
   910</sig_id><blocking_mask>2</blocking_mask><kw_data><buffer>QWNjZXB0OiAqLyoNCngtaGFja2VyOiBjYXQgL2V0Yy9wYXNzd2QNCg0K</buffer><offset>27</offset><length>11</length></kw_data></s\
   ig_data></violation></request-violations></BAD_MSG>",request="GET /txt HTTP/1.1\r\nHost: blue.f5demo.com\r\nUser-Agent: curl/7.58.0\r\nAccept: */*\r\nx-hacker: cat /etc/passwd\r\
   \n\r\n"#015


Removing the AS3 Declaration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the previous examples an AS3 declaration was deployed as a configmap.  To
delete the existing AS3 configuration you need to update the configmap label.

.. code-block:: sh

  $ kubectl label cm f5demo-as3-configmap as3=false --overwrite
  $ kubectl label cm nginx-as3-configmap as3=false --overwrite -n nginx-ingress

Tearing it all down
-------------------

To reset the environment run the following (this will remove EVERYTHING).

.. code-block::

  $ ./teardown_demo.sh
