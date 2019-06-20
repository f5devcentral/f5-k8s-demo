Kubernetes Setup [Reference]
============================

The following covers how the lab environment was setup using Kubespray.

This is provided as reference in case you want to build your own lab environment
or you need to update the existing environment.



node setup
----------

networking
~~~~~~~~~~

You will need to configure eth1 as a static ip.

Create "eth1.yaml" (will vary for different hosts)

.. code-block:: yaml

  network:
    version: 2
    renderer: networkd
    ethernets:
      eth1:
        addresses:
        - 10.1.10.11/24

now copy this into the netplan directory

.. code-block:: sh

  $ sudo cp eth1.yaml /etc/netplan/

apply the change (will also happen on reboots)

.. code-block:: sh

  $ sudo netplan apply

ssh keys
~~~~~~~~

generate ssh keys

.. code-block:: sh

  $ ssh-keygen

copy keys to node1-3

.. code-block:: sh

  $ cat >> .ssh/authorized_keys

kubespray
----------

The lab environment was built on ubuntu-18.04 using kubespray.

kubespray is a set of Ansible playbooks and more information can be found here_.

.. _here: https://github.com/kubernetes-sigs/kubespray

Download the version of kubespray that is for your release i.e. 1.13 uses version
2.9.0 of kubespray

.. code-block:: sh

  $ tar -zxvf kubespray-2.9.0.tar.gz

Install dependencies
~~~~~~~~~~~~~~~~~~~~

Make sure you have python3 install

.. code-block:: sh

  $ which python3
  /usr/bin/python3

Make sure you have virtualenv

.. code-block:: sh

  $ sudo apt install python3-venv

Create a virtualenv for the necessary files.

.. code-block:: sh

  $ python3 -m venv ~/venv

Activate you virtualenv

.. code-block:: sh

  $ source ~/venv/bin/activate

from your kubespray directory virtualenv

.. code-block:: sh
  # make sure you install ansible 2.7.x, 2.8.x did not work
  # at the time of this document
  $ pip install ansible==2.7.11
  $ pip install -r requirements.txt

Generate the cluster files from the sample.

.. code-block:: sh

  $ cp -rp inventory/sample/ inventory/mycluster

Specify the IPs that you will be using.

.. code-block:: sh

  $ IPS="10.1.10.11 10.1.10.21 10.1.10.22"

Run the script to generate the playbooks

.. code-block:: sh

  $ CONFIG_FILE=inventory/mycluster/hosts.yml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

Next you will need to modify the networking to use flannel.

Update ``inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml``

.. code-block:: text

  # Choose network plugin (cilium, calico, contiv, weave or flannel)
  # Can also be set to 'cloud', which lets the cloud provider setup appropriate routing
  kube_network_plugin: flannel

Now you will need to run the install process

.. code-block:: sh

  $ ansible-playbook -i inventory/mycluster/hosts.yml --become --become-user=root cluster.yml

When this completes you will need to copy the kubectl config.

.. code-block:: sh

  $ mkdir ~/.kube
  $ sudo cp /etc/kubernetes/admin.conf ~/.kube/config
  $ sudo chown ubuntu ~/.kube/config

After this completes you will need to manually update the daemon-set for Flannel
to reference eth1 instead of eth0.

.. code-block:: sh

  $ kubectl edit ds -n kube-system kube-flannel

Modify the command to add the ``eth1`` line

.. code-block:: text
  
  - command:
    - /opt/bin/flanneld
    - --ip-masq
    - --kube-subnet-mgr
    - --iface=eth1
