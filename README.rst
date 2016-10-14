centos-cloud
============
Setup tl;dr
-----------
From a CentOS7 minimal installation.

Controller::

    ssh root@controller
    yum -y install git
    git clone https://github.com/CentOS/centos-cloud
    cd centos-cloud
    ./bootstrap-controller.sh

Compute Node(s)::

    ssh root@compute01
    yum -y install git
    git clone https://github.com/CentOS/centos-cloud
    cd centos-cloud
    ./bootstrap-compute.sh

To generate test resources (ssh key, image, instance)::

    ssh root@compute01
    cd centos-cloud
    ./bootstrap-resources.sh

Architecture tl;dr
------------------
- Nova, Neutron, Keystone, Glance only (no Horizon, Swift, Cinder, Heat, Telemetry, etc.)
- No security groups, no floating IPs, no virtual routers, no metadata service
- Flat networking (no VLAN/VXLAN) with DHCP and LinuxBridge

Notes
-----
- Non-default credentials to services, databases and such are crypted with git-crypt
  inside the puppet/hiera/common.yaml file.
- There is an openrc with credentials generated in /root/ of controller and compute nodes
- To access a novnc console::

    openstack server list
    openstack console url show <vmuuid>
    # Access the URL via a tunnel or some other mean of reaching the private network

Ops
---
Ansible playbooks will be created as needed to help operating the cloud.

Ansible must be run from the controller node which has network and ssh key
authentication set up to the compute nodes.

manage-services.yml
~~~~~~~~~~~~~~~~~~~
::

    # Stop all OpenStack services only on compute nodes
    ansible-playbook -i hosts -l compute playbooks/manage-services.yml -e "action=stop"

    # Restart all OpenStack services on every host
    ansible-playbook -i hosts playbooks/manage-services.yml -e "action=restart"

    # Start all OpenStack services only on controller
    ansible-playbook -i hosts -l controller playbooks/manage-services.yml -e "action=start"


Create image
------------
You can create a base image using the create-image.sh script
::

    # For instance on Fedora 24
    dnf install -y libguestfs-tools
    ./create-image.sh


Todo
----
- SSL everywhere (let's encrypt?)
- Make sure you change the admin password once all the nodes are setup
