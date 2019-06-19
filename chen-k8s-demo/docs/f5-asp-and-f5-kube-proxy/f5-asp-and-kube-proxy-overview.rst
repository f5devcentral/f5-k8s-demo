F5 ASP and F5-kube-proxy overview
=================================


Deploying the F5® Application Services Proxy (ASP) in Kubernetes replaces kube-proxy. This allows you to annotate a Kubernetes Service to enable its ClusterIP to be implemented by the Application Services Proxy, while other services retain the basic kube-proxy behavior.

The F5® Application Services Proxy in Kubernetes is composed of two (2) parts:

* A privileged service that manages the iptables rules of the host
* The proxy that processes service traffic.

The Application Services Proxy should be deployed on every node in your Kubernetes cluster. The ASP on the same node as the client handles requests and load-balances to the backend pod. Application Services Proxy creates a virtual server for every Kubernetes Service in the cluster that has the F5 annotation configured 