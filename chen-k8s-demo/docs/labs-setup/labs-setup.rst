Labs setup/access
=================

In this section, we will cover our setup: 

* 1 basic cluster: 

	* 1 master (no master HA)
	* 2 nodes


Here is the setup we will leverage to either create a new environment or to connect to an existing environment (F5 UDF - Blueprint called *[Kubernetes] how to setup ASP and CC* )

In the existing environment, here is the setup you'll get: 

==================  ====================  ====================  ============  =============================================
     Hostname           Management IP        Kubernetes IP          Role                 Login/Password
==================  ====================  ====================  ============  =============================================
     ip-10-1-1-4          10.1.1.4            10.1.10.11          Master       ssh: ubuntu/<your key> - su : root/default           
     ip-10-1-1-5          10.1.1.5            10.1.10.21           node        ssh: ubuntu/<your key> - su : root/default
     ip-10-1-1-6          10.1.1.6            10.1.10.22           node        ssh: ubuntu/<your key> - su : root/default
     Windows              10.1.1.7            10.1.10.50        Jumpbox            administrator / &NUyBADsdo
==================  ====================  ====================  ============  =============================================


In case you don't use UDF and an existing blueprint, here are a few things to know that could be useful (if you want to reproduce this in another environment)

Here are the different things to take into accounts during this installation guide: 

* We use *Ubuntu xenial* in the UDF blueprints
* We updated on all the nodes the /etc/hosts file so that each node is reachable via its name

::

	#master and nodes host file
	$ cat /etc/hosts
	127.0.0.1       localhost
	10.1.10.11       ip-10-1-1-4 master1 master1.my-lab
	10.1.10.21       ip-10-1-1-5 node1  node1.my-lab
	10.1.10.22       ip-10-1-1-6 node2  node2.my-lab


You have many manuals available to explain how to install Kubernetes. If you don't use Ubuntu, you can reference to this page to find the appropriate guide:  `Getting started guides - bare metal  <http://kubernetes.io/docs/getting-started-guides/#bare-metal>`_ 

Here you'll find guides for:

* fedora
* Centos
* Ubuntu
* CoreOS
  
  and some other guides for non bare metal deployment (AWS, Google Compute Engine, Rackspace, ...)


