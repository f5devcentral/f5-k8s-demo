Building the Demo Environment
==============================

The demo environment is built in F5's UDF environment.

The UDF hypervisor is KVM and the process used is a variant of:

https://servicesblog.redhat.com/2019/07/11/installing-openshift-4-1-using-libvirt-and-kvm/

The Components
~~~~~~~~~~~~~~

Web Node
++++++++

The "web" node is used to host the RHCOS images and Ignition configs that are used during the build.

The openshift-install and oc commands are installed on this host.

OpenShift Nodes
+++++++++++++++

There are 3 OpenShift nodes.
- bootstrap
- control-plane (master)
- worker

Windows 10
++++++++++

This device is used to allow RDP connections to access the OpenShift console (web UI).

BIG-IP
++++++

The BIG-IP is configured to be used for DNS by the web host and windows 10.  Those hosts
have been manually changed to use the BIG-IP (unable to modify DHCP options in UDF).

Setup
~~~~~

Running openshift-install
+++++++++++++++++++++++++

The first step is to download the appropriate openshift-install and rhcos kernel/initrams/raw images (see OpenShift blog for details).

NGINX web server is being used to host these files.

Next we run the openshift-install with a basic install-config.yaml that will generate the ignition configs.

.. code-block:: YAML

    apiVersion: v1
    ## The base domain of the cluster. All DNS records will be sub-domains of this base and will also include the cluster name.
    baseDomain: example.com
    compute:
    - name: worker
    replicas: 1
    controlPlane:
    name: master
    replicas: 1
    metadata:
    ## The name for the cluster
    name: dc1
    platform:
    none: {}
    ## The pull secret that provides components in the cluster access to images for OpenShift components.
    pullSecret: '<get this from OpenShift Install portal>'
    ## The default SSH key that will be programmed for `core` user.
    sshKey: 'ssh key of centos@web user'

You can also modify the pull secret to disable phone home.

.. code-block:: shell

  $ ./openshift-install --dir ocp4 create ignition-configs

Copy the generated *.ign files to /usr/share/nginx/html

Setting up BIG-IP
+++++++++++++++++

There is a FAST template at: https://github.com/chen23/openshift-4-3

You can follow the prompts to build out the necessary DNS records.  Note at that AS3 3.20 has an issue
where you cannot generate SRV records that are used by etcd.  In the current BP BIND is also running on 
the web host, but in the future you should be able to host all of the DNS records on the BIG-IP.

Bootstrap Node
++++++++++++++

UDF does not include RHCOS.  Instead you will start with a CentOS 8 image and install RHCOS on top.

After you copy down the kernel/initrams of the RHCOS installer you can modify the boot process to run the installer.

.. code-block:: shell

  curl -O -L -J http://10.1.1.4/rhcos-4.3.8-x86_64-installer-kernel-x86_64
  curl -O -L -J http://10.1.1.4/rhcos-4.3.8-x86_64-installer-initramfs.x86_64.img
  mv rhcos-4.3.8-x86_64-installer-kernel-x86_64 /boot/vmlinuz-rhcos
  mv rhcos-4.3.8-x86_64-installer-initramfs.x86_64.img /boot/initramfs-rhcos.img

Here's an example of changing the system boot to run the installer.

.. code-block:: shell

    grubby --add-kernel=/boot/vmlinuz-rhcos --args="ip=10.1.1.5::10.1.1.1:255.255.255.0:bootstrap.dc1.example.com:ens5:none nameserver=10.1.10.10 \
            rd.neednet=1 coreos.inst=yes coreos.inst.install_dev=vda coreos.inst.image_url=http://10.1.1.4/rhcos-4.3.8-x86_64-metal.x86_64.raw.gz \
            coreos.inst.ignition_url=http://10.1.1.4/bootstrap.ign console=ttyS0" --initrd=/boot/initramfs-rhcos.img --make-default --title=rhcos

You can monitor the status of the install by checking the console.

Once the bootstrap node is up you can monitor the status by logging into the host (using username "core" and ssh key that
you specified in the install-config.yaml).

You can also monitor the status using openshift-install command.

Other Nodes
+++++++++++

You can then boot up the other nodes using a similar process, but modifying for the appropriate IP address and ignition config role.

Post Setup
~~~~~~~~~~

The certificates take a while to stabilize.  There's tricks to getting them to work that you should be aware of: 
https://github.com/redhat-cop/openshift-lab-origin/blob/master/OpenShift4/Stopping_and_Resuming_OCP4_Clusters.adoc

In the UDF environment I had to manually update /etc/hosts to add the hostname of the VM.  Otherwise the system would start
before DNS was ready and have the name "localhost".

Installing Container Ingress Services
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can install Container Ingress Services by going to the Operator Hub.  Make sure to create your secret for the credential first.

Connecting to a private Docker repo
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

I found that I had to manually install an internal CA certificate onto the worker node and run update-ca.  You should be able to
do this using MachineConfig, but it did not work for me.

Appendix
~~~~~~~~

BIND Zone
+++++++++

Ideally you would use BIG-IP DNS for all the records, but you could also set them up using BIND.

You will also want to create a reverse PTR.

.. code-block::

  $TTL 1W
  @       IN      SOA     ns1.example.com.        root (
                          2019070700      ; serial
                          3H              ; refresh (3 hours)
                          30M             ; retry (30 minutes)
                          2W              ; expiry (2 weeks)
                          1W )            ; minimum (1 week)
          IN      NS      ns1.example.com.
  ;
  ;
  ns1     IN      A       10.1.1.4
  ;
  ; The api points to the IP of your load balancer
  api             IN      A       10.1.10.10
  api-int         IN      A       10.1.10.10
  ;
  ; The wildcard also points to the load balancer
  *.apps          IN      A       10.1.10.10
  ;
  ; Create entry for the bootstrap host
  bootstrap       IN      A       10.1.1.7
  ;
  ; Create entries for the master hosts
  master          IN      A       10.1.1.8
  ;
  ; Create entries for the worker hosts
  worker-0                IN      A       10.1.1.9
  ;
  ; The ETCd cluster lives on the masters...so point these to the IP of the masters
  etcd-0  IN      A       10.1.1.8
  ;
  ; The SRV records are IMPORTANT....make sure you get these right...note the trailing dot at the end...
  _etcd-server-ssl._tcp   IN      SRV     0 10 2380 etcd-0.dc1.example.com.
  ;
  f5oauth IN      A       10.1.10.200
  ;
  vpn     IN      A       10.1.10.201
  ;
  api-proxy       IN      A       10.1.10.202
  ;
  bigip1  IN      A       10.1.1.6
  ;
  ;EOF