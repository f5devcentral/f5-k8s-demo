Kubernetes services overview
============================

Refer to `Kubernetes services <http://kubernetes.io/docs/user-guide/services/>`_ for more information 

A Kubernetes *service* is an abstraction which defines a logical set of *pods* and a policy by which to access them. The set of *pods* targeted by a *service* is (usually) determined by a *label selector*.

As an example, consider an image-processing backend which is running with 3 replicas. Those replicas are fungible - frontends do not care which backend they use. While the actual *pods* that compose the backend set may change, the frontend clients should not need to be aware of that or keep track of the list of backends themselves. The *service* abstraction enables this decoupling.

For Kubernetes-native applications, Kubernetes offers a simple *Endpoints API* that is updated whenever the set of *pods* in a *service* changes. For non-native applications, Kubernetes offers a virtual-IP-based bridge to *services* which redirects to the backend *pods*.

Defining a service
------------------

A *service* in Kubernetes is a REST object, similar to a *pod*. Like all of the REST objects, a *service* definition can be *POSTed* to the *apiserver* to create a new instance. For example, suppose you have a set of *pods* that each expose port 9376 and carry a *label* "app=MyApp".

.. code::

	{
	    "kind": "Service",
	    "apiVersion": "v1",
	    "metadata": {
	        "name": "my-service"
	    },
	    "spec": {
	        "selector": {
	            "app": "MyApp"
	        },
	        "ports": [
	            {
	                "protocol": "TCP",
	                "port": 80,
	                "targetPort": 9376
	            }
	        ]
	    }
	}

This specification will create a new *service* object named "my-service" which targets TCP port 9376 on any *pod* with the "app=MyApp" *label*. 

This *service* will also be assigned an IP address (sometimes called the *cluster IP*), which is used by the *service proxies* . The *service’s selector* will be evaluated continuously and the results will be POSTed to an *Endpoints* object also named “my-service”. 

if the service is not a native kubernetes app, then you can do a service definition without the *selector* field. In such a case you'll have to specify yourself the *endpoints* 

.. code::

	{
	    "kind": "Service",
	    "apiVersion": "v1",
	    "metadata": {
	        "name": "my-service"
	    },
	    "spec": {
	        "ports": [
	            {
	                "protocol": "TCP",
	                "port": 80,
	                "targetPort": 9376
	            }
	        ]
	    }
	}

	{
	    "kind": "Endpoints",
	    "apiVersion": "v1",
	    "metadata": {
	        "name": "my-service"
	    },
	    "subsets": [
	        {
	            "addresses": [
	                { "ip": "1.2.3.4" }
	            ],
	            "ports": [
    	            { "port": 9376 }
        	    ]
        	}
    	]
	}

Note that a *service* can map an incoming port to any *targetPort*. By default the *targetPort* will be set to the same value as the *port* field. In the example above, the port for the service is 80 (HTTP) and will redirect traffic to port 9376 on the Pods

You can specify multiple ports if needed (like HTTP/HTTPS for an app)

Kubernetes *service* supports TCP (default) and UDP.

Publishing services - service types
-----------------------------------

For some parts of your application (e.g. frontends) you may want to expose a *Service* onto an external (outside of your cluster, maybe public internet) IP address, other services should be visible only from inside of the cluster.

Kubernetes ServiceTypes allow you to specify what kind of *service* you want. **The default and base type is *ClusterIP*, which exposes a *service* to connection from inside the cluster**. NodePort and LoadBalancer are two types that expose services to external traffic.

Valid values for the ServiceType field are:

 * ExternalName: map the *service* to the contents of the externalName field (e.g. foo.bar.example.com), by returning a CNAME record with its value. No proxying of any kind is set up. This requires version 1.7 or higher of kube-dns.

 * ClusterIP: use a cluster-internal IP only - this is the default and is discussed above. Choosing this value means that you want this *service* to be reachable only from inside of the *cluster*.

 * NodePort: on top of having a cluster-internal IP, expose the *service* on a port on each node of the cluster (the same port on each *node*). You’ll be able to contact the service on any <NodeIP>:NodePort address. If you set the type field to "NodePort", the Kubernetes master will allocate a port from a flag-configured range **(default: 30000-32767)**, and each Node will proxy that port (the same port number on every Node) into your *Service*. That port will be reported in your Service’s spec.ports[*].nodePort field.

  If you want a specific port number, you can specify a value in the nodePort field, and the system will allocate you that port or else the API transaction will fail (i.e. you need to take care about possible port collisions yourself). **The value you specify must be in the configured range for node ports**.

 * LoadBalancer: on top of having a cluster-internal IP and exposing service on a NodePort also, ask the cloud provider for a load balancer which forwards to the Service exposed as a <NodeIP>:NodePort for each Node
  
Service type: LoadBalancer
--------------------------

On cloud providers which support external load balancers, setting the type field to "LoadBalancer" will provision a load balancer for your *Service*. The actual creation of the load balancer happens asynchronously, and information about the provisioned balancer will be published in the Service’s status.loadBalancer field. For example:

.. code::

	{
	    "kind": "Service",
	    "apiVersion": "v1",
	    "metadata": {
	        "name": "my-service"
	    },
	    "spec": {
	        "selector": {
	            "app": "MyApp"
	        },
	        "ports": [
	            {
	                "protocol": "TCP",
	                "port": 80,
	                "targetPort": 9376,
	                "nodePort": 30061
	            }
	        ],
	        "clusterIP": "10.0.171.239",
	        "loadBalancerIP": "78.11.24.19",
	        "type": "LoadBalancer"
    	},
	    "status": {
	        "loadBalancer": {
	            "ingress": [
	                {
	                    "ip": "146.148.47.155"
	                }
	            ]
	        }
	    }
	}

 Traffic from the external load balancer will be directed at the backend *Pods*, though exactly how that works depends on the cloud provider (AWS, GCE, ...). Some cloud providers allow the loadBalancerIP to be specified. In those cases, the load-balancer will be created with the user-specified loadBalancerIP. If the loadBalancerIP field is not specified, an ephemeral IP will be assigned to the loadBalancer. If the loadBalancerIP is specified, but the cloud provider does not support the feature, the field will be ignored

Service proxies
---------------

Every node in a Kubernetes cluster runs a *kube-proxy*. *kube-proxy* is responsible for implementing a form of virtual IP for *Services*

Since Kubernetes 1.2,  the iptables proxy is the default behavior (another implementation of kube-proxy is the userspace implementation)

In this mode, *kube-proxy* watches the Kubernetes *master* for the addition and removal of *Service* and *Endpoints* objects. For each*Service*, it installs iptables rules which capture traffic to the *Service*’s *cluster IP* (which is virtual) and *Port* and redirects that traffic to one of the *Service*’s backend sets. For each *Endpoints* object, it installs iptables rules which select a backend *Pod*.

By default, the choice of backend is random. Client-IP based session affinity can be selected by setting **service.spec.sessionAffinity** to "ClientIP" (the default is "None").

As with the userspace proxy, the net result is that any traffic bound for the *Service*’s IP:Port is proxied to an appropriate backend without the clients knowing anything about Kubernetes or *Services* or *Pods*. This should be faster and more reliable than the userspace proxy. However, unlike the userspace proxier, the iptables proxier cannot automatically retry another *Pod* if the one it initially selects does not respond, so it depends on having working *readiness probes*. A readiness probes give you the capability to monitor the status of a *pod* via health-checks

Service discovery
-----------------

The recommended way to implement Service discovery with Kubernetes is the same as with Mesos: DNS

when building a cluster, you can add *add-on* to it. One of the available *add-on* is a DNS Server. 

 The DNS server watches the Kubernetes API for new *Services* and creates a set of DNS records for each. If DNS has been enabled throughout the cluster then all *Pods* should be able to do name resolution of Services automatically.
 

For example, if you have a *Service* called "my-service" in Kubernetes Namespace "my-ns" a DNS record for "my-service.my-ns" is created. *Pods* which exist in the "my-ns" Namespace should be able to find it by simply doing a name lookup for "my-service". *Pods* which exist in other Namespaces must qualify the name as "my-service.my-ns". The result of these name lookups is the *cluster IP*.

Kubernetes also supports DNS SRV (service) records for named ports. If the "my-service.my-ns" *Servic*e has a port named "http" with protocol TCP, you can do a DNS SRV query for "_http._tcp.my-service.my-ns" to discover the port number for "http"