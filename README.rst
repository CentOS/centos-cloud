centos-cloud
============
Setup tl;dr
-----------
From a CentOS7 minimal installation.

Controller::

    ssh root@controller
    yum -y install git
    git clone https://github.com/dmsimard/centos-cloud
    cd centos-cloud
    ./bootstrap-controller.sh

Compute Node(s)::

    ssh root@compute01
    yum -y install git
    git clone https://github.com/dmsimard/centos-cloud
    cd centos-cloud
    ./bootstrap-compute.sh <ipaddress_of_controller>

To generate test resources (ssh key, image, instance)::

    ssh root@compute01
    cd centos-cloud
    ./bootstrap-resources.sh

Architecture tl;dr
------------------
- Nova, Neutron, Keystone, Glance, Horizon only (no Swift, Cinder, Heat, Telemetry, etc.)
- No security groups, no floating IPs, no virtual routers, no metadata service
- Flat networking (no VLAN/VXLAN) with DHCP and LinuxBridge (cloud-init lacks a feature to remove the need for DHCP)

Notes
-----
- The root password of the instance is hardcoded in the image as "root" for test purposes.
- There is an openrc with credentials generated in /root/ of controller and compute nodes
- To access a novnc console::

    openstack server list
    openstack console url show <vmuuid>
    # Access the URL via a tunnel or some other mean of reaching the private network

Todo
----
- SSL everywhere (let's encrypt?)
- Probably configure keystone token driver and cache to something else than memcached (fernet?)
- It's kind of slow, haven't looked into that yet. Maybe it's related to keystone authentication.
- Make sure you change the admin password once all the nodes are setup
