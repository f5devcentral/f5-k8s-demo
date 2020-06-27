Add Some Apps
=============

The first step is that we are going to add a bunch of apps.

In OpenShift/Kubernetes a "Deployment" represents that information about
which container you want to deploy and any configuration.

A "Service" provides a mechanism to make a deployment available within
the cluster or outside of the cluster.

Run the following commands to deploy a set of applications and services.

(Recommended that you copy-and-paste!)

.. code-block:: shell

    oc create -f my-frontend-deployment2.yaml
    oc create -f my-frontend-deployment3.yaml
    oc create -f my-frontend-deployment.yaml
    oc create -f www-deployment.yaml

    oc create -f my-frontend-service2-as3.yaml
    oc create -f my-frontend-service3-as3.yaml
    oc create -f my-frontend-service.yaml
    oc create -f www-service.yaml

Now run "oc get svc".  This will output information about the services
that you deployed.  You should see similar output.

.. code-block:: shell

    $ oc get svc
    NAME           TYPE           CLUSTER-IP      EXTERNAL-IP                            PORT(S)        AGE
    kubernetes     ClusterIP      172.30.0.1      <none>                                 443/TCP        14d
    my-frontend    ClusterIP      172.30.127.17   <none>                                 80/TCP         7s
    my-frontend2   NodePort       172.30.252.4    <none>                                 80:31282/TCP   7s
    my-frontend3   NodePort       172.30.90.4     <none>                                 80:30628/TCP   7s
    openshift      ExternalName   <none>          kubernetes.default.svc.cluster.local   <none>         14d
    sleep          ClusterIP      172.30.50.240   <none>                                 80/TCP         13d
    www            ClusterIP      172.30.245.20   <none>                                 443/TCP        5s

Note that my-frontend2/3 is using "NodePort".  This means that the cluster
is exposing the service via port address translation.  

In the example above (yours will differ) I should be able to access "my-frontend2" by 
going to one of the worker nodes on port "31282".  Find the port number 
in your environment and try running the following command (using the port number that you see).

.. code-block:: text

  $ curl 10.1.1.9:31282/txt
    ================================================
    ___ ___   ___                    _
    | __| __| |   \ ___ _ __  ___    /_\  _ __ _ __
    | _||__ \ | |) / -_) '  \/ _ \  / _ \| '_ \ '_ \
    |_| |___/ |___/\___|_|_|_\___/ /_/ \_\ .__/ .__/
                                        |_|  |_|
    ================================================

        Node Name: CIS ConfigMap
        Short Name: my-frontend2-d54f79c77-lh2j2

        Server IP: 10.128.0.125
        Server Port: 8080

        Client IP: 10.128.0.1
        Client Port: 33944

    Client Protocol: HTTP
    Request Method: GET
        Request URI: /txt

        host_header: 10.1.1.9
        user-agent: curl/7.61.1
  
Note that the originating IP address is 10.128.0.1.  This is coming
from the internal L4 proxy of OpenShift.



