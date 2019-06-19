.. _my-cluster-setup:

Cluster installation
====================

Overview
--------

As a reminder, in this example, this is our cluster setup:

==================  ====================  ====================  ============
     Hostname           Management IP        Kubernetes IP          Role
==================  ====================  ====================  ============
     Master 1             10.1.1.4            10.1.10.11          Master
      node 1              10.1.1.5            10.1.10.21           node
      node 2              10.1.1.6            10.1.10.22           node
==================  ====================  ====================  ============

.. warning::

        This guide is for Kubernetes version 1.7.11

For this setup we will leverage **kubeadm** to install Kubernetes on your own Ubuntu Servers version 16.04; steps we are going to use are specified in details here: `Ubuntu getting started guide 16.04 <http://kubernetes.io/docs/getting-started-guides/kubeadm/>`

If you think you'll need a custom solution installed on on-premises VMs, please refer to this documentation: `Kubernetes on Ubuntu <https://kubernetes.io/docs/getting-started-guides/ubuntu/>`_

Here are the steps that are involved (detailed later):

1. make sure that firewalld is disabled (not supported today with kubeadm)
2. disable Apparmor
3. make sure all systems are up to date
4. install docker if not already done (many kubernetes services will run into containers for reliability)
5. install kubernetes packages

To make sure the systems are up to date, run these commands on **all systems**:

.. warning::

	Make sure that your /etc/hosts files on master and nodes resolve your hostnames with 10.1.10.X IPs

installation
-------------

We need to be sure the Ubuntu OS is up to date, we add Kubernetes repository to the list ov available Ubuntu package sources and we install Kubernetes packages for version 1.7.x, making sure to hold with this version even when upgrading the OS. This procedure will install Docker on all systems because most of the component of Kubernetes will leverage this container technology.

As previously said, you need **root privileges** for this section, either use sudo or su to gain the required privileges; morover be sure to execute this procedure on **all systems**.

::

    sudo apt-get update
    sudo apt-get -y upgrade
    sudo apt-get install -y apt-transport-https
    sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    sudo cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
    deb http://apt.kubernetes.io/ kubernetes-xenial main
    EOF
    sudo apt-get update

    sudo apt-get -y install kubectl=1.7.11-00 kubelet=1.7.11-00 kubernetes-cni=0.5.1-00 kubeadm=1.7.11-00
    sudo apt-mark hold kubeadm kubectl kubelet kubernetes-cni

Once this is done, install docker if not already done on **all systems**:

::

	sudo apt-get install -y docker.io


Limitations
-----------

for a full list of the limitations go here: `kubeadm limitations <http://kubernetes.io/docs/getting-started-guides/kubeadm/#limitations>`_

.. warning::

        The cluster created here has a single master, with a single etcd database running on it. This means that if the master fails, your cluster loses its configuration data and will need to be recreated from scratch
