Lab 1.1 - Deploying an Application in Kubernetes
================================================

This exercise will cover the basics of deploying an application in Kubernetes.

Deploy an application
---------------------

The YAML represents a ``Deployment`` which tell Kubernetes to deploy a pod. The
``name`` of this ``Deployment`` is ``coffee``. There should be 2 ``replicas``
of the pod at the time of deployment. Each pod should consist of 1 container
built from the ``nginxdemos/hello`` docker image with the ``plain-text`` tag.
Port ``80`` inside the container should be exposed to the cluster. 

**Run these commands from the K8S Master node.**

.. code:: shell

   kubectl create -f - <<'EOF'
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: coffee
   spec:
     replicas: 2
     selector:
       matchLabels:
         app: coffee
     template:
       metadata:
         labels:
           app: coffee
       spec:
         containers:
         - name: coffee
           image: nginxdemos/hello:plain-text
           ports:
           - containerPort: 80
   EOF
  
Verify your application is running
----------------------------------

Run the following command to see a list of pods that are running.

.. code:: shell

   kubectl get po
  

.. NOTE:: ``po`` is short for ``pod``.  In this command you are getting a 
   list of all the containers that are running in the "default" namespace (-n).
   Kubernetes makes use of namespaces to separate services (similiar to 
   BIG-IP Administrative Partitions).

You should see output similar to:

.. code:: shell

   ubuntu@kmaster:~$ kubectl get po
   NAME                                    READY   STATUS    RESTARTS   AGE
   coffee-bbd45c6-6ptzj                    1/1     Running   0          2m18s
   coffee-bbd45c6-blhck                    1/1     Running   0          2m18s

Add the "-o wide" command to see the pod IP addresses.

.. code:: shell

   kubectl get po -o wide
  
Expected output:

.. code:: shell
  
   ubuntu@kmaster:~$ kubectl get po -o wide
   NAME                                    READY   STATUS    RESTARTS   AGE     IP            NODE      NOMINATED NODE   READINESS GATES
   coffee-bbd45c6-6ptzj                    1/1     Running   0          3m11s   10.244.2.84   knode2    <none>           <none>
   coffee-bbd45c6-blhck                    1/1     Running   0          3m11s   10.244.1.91   knode1    <none>           <none>
   ..

.. tip:: You may also see other pods like "registry" that are running.
  
.. NOTE:: Observe that the pods are both running on knode1, though there are
   two nodes (knode1 and knode2) and that the IP addresses are outside the
   routable range of the environment (10.1.0.0/16 in UDF). The pod IP addresses
   are in the cluster overlay network.
   
Use the following command to show all pods from all namespaces and you will
notice that the pods are evenly diviated.

.. code:: shell

   kubectl get po -o wide --all-namespaces
  
Re-type to get the PODs' IP addresses.

.. code:: shell

   kubectl get po -o wide
  
Use the ``curl`` command to test whether your application is running.

.. code:: shell
  
    curl [pod IP]
  
For example (your pod IP address will be different):

.. code:: shell

   ubuntu@kmaster:~$ curl 10.244.2.84
   Server address: 10.244.2.84:80
   Server name: coffee-bbd45c6-6ptzj
   Date: 09/May/2019:14:42:33 +0000
   URI: /
   Request ID: 8f7bfd37fdc6b4b24403c92d196494be
  
.. attention:: Congratulations you have deployed an application!
