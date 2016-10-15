Creating a project
==================
Creating a project is an administrator-only task.

::

    # Create the project
    openstack project create projectname
    # Create the user and add it to the project
    openstack user create username --project projectname --password "duffy-api-key" --email "email@domain.tld"
    # Add the member role for the new user on the new project
    openstack role add _member_ --user username --project projectname
    # Allow admin to authenticate inside this project
    openstack role add _member_ --user admin --project projectname

The ``openrc`` file to use based on the above configuration would be:

::

    #!/bin/sh
    export OS_NO_CACHE='true'
    export OS_PROJECT_NAME='projectname'
    export OS_USERNAME='username'
    export OS_PASSWORD='duffy-api-key'
    export OS_AUTH_URL='http://controller.openstack.ci.centos.org:5000/v3/'
    export OS_AUTH_STRATEGY='keystone'
    export OS_REGION_NAME='RegionOne'
    export OS_PROJECT_DOMAIN_NAME='default'
    export OS_USER_DOMAIN_NAME='default'
    export CINDER_ENDPOINT_TYPE='publicURL'
    export GLANCE_ENDPOINT_TYPE='publicURL'
    export KEYSTONE_ENDPOINT_TYPE='publicURL'
    export NOVA_ENDPOINT_TYPE='publicURL'
    export NEUTRON_ENDPOINT_TYPE='publicURL'
    export OS_IDENTITY_API_VERSION='3'

Modifying quotas for a project
==============================
Modifying quotas for a project is an administrator-only task.

Those are the default quotas:

::

    +----------------------+----------------------------------+
    | Field                | Value                            |
    +----------------------+----------------------------------+
    | cores                | 20                               |
    | fixed-ips            | 20                               |
    | floating-ips         | 10                               |
    | injected-file-size   | 10240                            |
    | injected-files       | 5                                |
    | injected-path-size   | 255                              |
    | instances            | 20                               |
    | key-pairs            | 100                              |
    | network              | 1                                |
    | port                 | 20                               |
    | project              | 09a01c4d114f440abdd66cba92270ac9 |
    | properties           | 128                              |
    | ram                  | 40960                            |
    | rbac_policy          | 10                               |
    | secgroup-rules       | 100                              |
    | secgroups            | 10                               |
    | security_group_rules | 0                                |
    | security_groups      | 0                                |
    | server_group_members | 10                               |
    | server_groups        | 10                               |
    | subnet               | 1                                |
    | subnetpool           | -1                               |
    +----------------------+----------------------------------+

To modify a quota:

::

    $ openstack help quota set
    usage: openstack quota set [-h] [--class] [--properties <properties>]
                               [--ram <ram>] [--secgroup-rules <secgroup-rules>]
                               [--instances <instances>] [--key-pairs <key-pairs>]
                               [--fixed-ips <fixed-ips>] [--secgroups <secgroups>]
                               [--injected-file-size <injected-file-size>]
                               [--floating-ips <floating-ips>]
                               [--injected-files <injected-files>]
                               [--cores <cores>]
                               [--injected-path-size <injected-path-size>]
                               [--gigabytes <gigabytes>] [--volumes <volumes>]
                               [--snapshots <snapshots>]
                               [--volume-type <volume-type>]
                               <project/class>

Creating a virtual machine (without Duffy)
==========================================
To create and use a virtual machine, you first need to browse through the
existing images, networks and flavors to know what configuration to pick.
You also need to have a SSH keypair setup.

SSH keypair
-----------
Public keys can be added to Nova. This will allow you to have Nova configure
ssh key authentication on newly created virtual machines automatically.

::

    openstack keypair create keypairname --public-key <filename.pub>

    +-------------+-------------------------------------------------+
    | Field       | Value                                           |
    +-------------+-------------------------------------------------+
    | fingerprint | dd:96:d7:c5:e1:12:6f:15:8a:7c:fe:29:ea:2d:8e:47 |
    | name        | keypairname                                     |
    | user_id     | 7a68bb53f1f0499d9ab64c4bca697bce                |
    +-------------+-------------------------------------------------+

Image
-----
Images are what your virtual machines will use to boot. These have generally
been provisioned in advance for you. You need to select and choose one:

::

    $ openstack image list
    +--------------------------------------+-----------+--------+
    | ID                                   | Name      | Status |
    +--------------------------------------+-----------+--------+
    | 61c0afed-c9e6-4e1f-b749-d274793bff2b | CentOS 6  | active |
    | f04bd64c-5c64-4ad2-a9a3-c8921d2c0f71 | Fedora 24 | active |
    | 1f8015ef-a6a1-4882-aa99-6c63375d4c3a | CentOS 7  | active |
    +--------------------------------------+-----------+--------+

Network
-------
Networks are where your virtual machine will get it's IP address from.
These have generally been provisioned in advance for you. You need to select
and choose one:

::

    $ openstack network list
    +--------------------------------------+-----------+--------------------------------------+
    | ID                                   | Name      | Subnets                              |
    +--------------------------------------+-----------+--------------------------------------+
    | 4fef18ca-6f42-4e9d-b2af-063bd3d320fe | publicnet | ee3b905e-70af-4c5f-8355-11dbc7e10808 |
    +--------------------------------------+-----------+--------------------------------------+

Flavor
------
Flavors define the specifications of your virtual machines. How much vCPUs, RAM
and disk space it will have. You need to select and choose one:

::

    $ openstack flavor list
    +--------------------------------------+--------+------+------+-----------+-------+-----------+
    | ID                                   | Name   |  RAM | Disk | Ephemeral | VCPUs | Is Public |
    +--------------------------------------+--------+------+------+-----------+-------+-----------+
    | 21ab27b0-aa65-4403-ba9d-89c866a1c181 | tiny   | 1940 |   10 |         0 |     1 | True      |
    | 6b0f60f5-d916-4d9a-bbf0-57acda2b7f0e | small  | 3875 |   20 |         0 |     2 | True      |
    | bc0f875d-f77b-4453-9916-d67ce6723693 | medium | 7750 |   40 |         0 |     4 | True      |
    +--------------------------------------+--------+------+------+-----------+-------+-----------+

Creating the virtual machine
----------------------------
Based on the above, creating a virtual machine with the following configuration:

- ``name``: test-server
- ``keypair``: keypairname
- ``image``: CentOS 7
- ``network``: publicnet (4fef18ca-6f42-4e9d-b2af-063bd3d320fe)
- ``flavor``: small

The appropriate command line to create it would be:

::

    openstack server create test-server \
        --key-name keypairname \
        --image 'CentOS 7' \
        --nic net-id=4fef18ca-6f42-4e9d-b2af-063bd3d320fe \
        --flavor small

    +--------------------------------------+-------------------------------------------------+
    | Field                                | Value                                           |
    +--------------------------------------+-------------------------------------------------+
    | OS-DCF:diskConfig                    | MANUAL                                          |
    | OS-EXT-AZ:availability_zone          |                                                 |
    | OS-EXT-SRV-ATTR:host                 | None                                            |
    | OS-EXT-SRV-ATTR:hypervisor_hostname  | None                                            |
    | OS-EXT-SRV-ATTR:instance_name        | instance-00000001                               |
    | OS-EXT-STS:power_state               | NOSTATE                                         |
    | OS-EXT-STS:task_state                | scheduling                                      |
    | OS-EXT-STS:vm_state                  | building                                        |
    | OS-SRV-USG:launched_at               | None                                            |
    | OS-SRV-USG:terminated_at             | None                                            |
    | accessIPv4                           |                                                 |
    | accessIPv6                           |                                                 |
    | addresses                            |                                                 |
    | adminPass                            | AAQDbueW82uD                                    |
    | config_drive                         |                                                 |
    | created                              | 2016-10-15T13:22:38Z                            |
    | flavor                               | small (6b0f60f5-d916-4d9a-bbf0-57acda2b7f0e)    |
    | hostId                               |                                                 |
    | id                                   | b7eddf6b-4807-49ff-8fb0-e66b42386289            |
    | image                                | CentOS 7 (1f8015ef-a6a1-4882-aa99-6c63375d4c3a) |
    | key_name                             | keypairname                                     |
    | name                                 | test-server                                     |
    | os-extended-volumes:volumes_attached | []                                              |
    | progress                             | 0                                               |
    | project_id                           | bdee047b7a0b4f4d8a98f66b2377d9bb                |
    | properties                           |                                                 |
    | security_groups                      | [{u'name': u'default'}]                         |
    | status                               | BUILD                                           |
    | updated                              | 2016-10-15T13:22:39Z                            |
    | user_id                              | 7a68bb53f1f0499d9ab64c4bca697bce                |
    +--------------------------------------+-------------------------------------------------+
