class centos_cloud::controller::provision {
  ###
  # Nova
  ###
  Keystone_user_role['admin@openstack'] -> Nova_flavor<||>

  nova_flavor { 'tiny':
    ensure => present,
    ram    => '2048',
    disk   => '20',
    vcpus  => '1',
  }

  nova_flavor { 'small':
    ensure => present,
    ram    => '4096',
    disk   => '40',
    vcpus  => '2',
  }

  nova_flavor { 'medium':
    ensure => present,
    ram    => '8192',
    disk   => '80',
    vcpus  => '4',
  }

  ###
  # Neutron
  ###
  Keystone_user_role['admin@openstack'] -> Neutron_network<||>
  Keystone_user_role['admin@openstack'] -> Neutron_subnet<||>

  neutron_network { 'publicnet':
    shared                    => true,
    provider_network_type     => 'flat',
    provider_physical_network => 'physnet0',
  }

  neutron_subnet { 'publicsubnet':
    cidr             => '172.19.4.0/21',
    gateway_ip       => '172.19.3.254',
    network_name     => 'publicnet',
    dns_nameservers  => ['172.19.0.12'],
    allocation_pools => ['start=172.19.4.10,end=172.19.7.250'],
  }

  ###
  # Glance
  ###
  Keystone_user_role['admin@openstack'] -> Glance_image<||>

  glance_image { 'CentOS 7':
    ensure           => present,
    container_format => 'bare',
    disk_format      => 'qcow2',
    is_public        => 'yes',
    source           => 'http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2'
  }

  glance_image { 'CentOS 6':
    ensure           => present,
    container_format => 'bare',
    disk_format      => 'qcow2',
    is_public        => 'yes',
    source           => 'http://cloud.centos.org/centos/6/images/CentOS-6-x86_64-GenericCloud.qcow2'
  }

  glance_image { 'Fedora 24':
    ensure           => present,
    container_format => 'bare',
    disk_format      => 'qcow2',
    is_public        => 'yes',
    source           => 'https://download.fedoraproject.org/pub/fedora/linux/releases/24/CloudImages/x86_64/images/Fedora-Cloud-Base-24-1.2.x86_64.qcow2'
  }
}
