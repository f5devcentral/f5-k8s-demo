Kubernetes networking
=====================

This is an extract from `Networking in Kubernetes <http://http://kubernetes.io/docs/admin/networking/>`_

Summary
-------

Kubernetes assumes that pods can communicate with other pods, regardless of which host they land on. We give every pod its own IP address so you do not need to explicitly create links between pods and you almost never need to deal with mapping container ports to host ports. This creates a clean, backwards-compatible model where pods can be treated much like VMs or physical hosts from the perspectives of port allocation, naming, service discovery, load balancing, application configuration, and migration

Docker model
------------

Before discussing the Kubernetes approach to networking, it is worthwhile to review the “normal” way that networking works with Docker. 

By default, Docker uses host-private networking. It creates a virtual bridge, called docker0 by default, and allocates a subnet from one of the private address blocks defined in `RFC1918 <https://tools.ietf.org/html/rfc1918>`_ for that bridge. 
For each container that Docker creates, it allocates a virtual ethernet device (called veth) which is attached to the bridge. The veth is mapped to appear as eth0 in the container, using Linux namespaces. The in-container eth0 interface is given an IP address from the bridge’s address range.
The result is that Docker containers can talk to other containers only if they are on the same machine (and thus the same virtual bridge). Containers on different machines can not reach each other - in fact they may end up with the exact same network ranges and IP addresses.
In order for Docker containers to communicate across nodes, they must be allocated ports on the machine’s own IP address, which are then forwarded or proxied to the containers. This obviously means that containers must either coordinate which ports they use very carefully or else be allocated ports dynamically.

Kubernetes model
----------------

Coordinating ports across multiple developers is very difficult to do at scale and exposes users to cluster-level issues outside of their control. 
Dynamic port allocation brings a lot of complications to the system - every application has to take ports as flags, the API servers have to know how to insert dynamic port numbers into configuration blocks, services have to know how to find each other, etc. Rather than deal with this, Kubernetes takes a different approach.

Kubernetes imposes the following fundamental requirements on any networking implementation (barring any intentional network segmentation policies):

* All containers can communicate with all other containers without NAT
* All nodes can communicate with all containers (and vice-versa) without NAT
* The IP that a container sees itself as is the same IP that others see it as
* What this means in practice is that you can not just take two computers running Docker and expect Kubernetes to work. You must ensure that the fundamental requirements are met.

Kubernetes applies IP addresses at the *Pod* scope - containers within a Pod share their network namespaces - including their IP address. This means that containers within a Pod can all reach each other’s ports on **localhost**. This does imply that containers within a Pod must coordinate port usage, but this is no different than processes in a VM. 
We call this the *IP-per-pod* model. This is implemented in Docker as a *pod container* which holds the network namespace open while “app containers” (the things the user specified) join that namespace with Docker’s **--net=container:<id>** function

How to achieve this
-------------------

There are a number of ways that this network model can be implemented. Here is a list of possible options:

* `Contiv <https://github.com/contiv/netplugin>`_
* `Flannel <https://github.com/coreos/flannel#flannel>`_
* `Open vswitch <http://kubernetes.io/docs/admin/ovs-networking>`_ 
* L2 networks and linux bridging. You have a tutorial `here <http://blog.oddbit.com/2014/08/11/four-ways-to-connect-a-docker/>`_
* `Project Calico <http://docs.projectcalico.org/>`_
* `Romana <http://romana.io/>`_
* `Weave net <https://www.weave.works/products/weave-net/>`_

For this lab, we will use Flannel. 
