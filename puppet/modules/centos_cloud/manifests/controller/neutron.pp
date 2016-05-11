class centos_cloud::controller::neutron (
  $allowed_hosts = "172.22.6.0/23",
  $controller    = 'controller.openstack.ci.centos.org',
  $bind_host     = '0.0.0.0',
  $rabbit_port   = '5672',
  $user          = 'neutron',
  $password      = 'neutron',
  $nova_password = 'nova'
) {

  rabbitmq_user { $user:
    admin    => true,
    password => $password,
    provider => 'rabbitmqctl',
    require  => Class['::rabbitmq']
  }

  rabbitmq_user_permissions { "${user}@/":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
    provider             => 'rabbitmqctl',
    require              => Class['::rabbitmq']
  }

  class { '::neutron::db::mysql':
    allowed_hosts => [$controller, $allowed_hosts],
    password      => $password,
    user          => $user
  }

  class { '::neutron::keystone::auth':
    admin_url    => "http://${controller}:9696",
    internal_url => "http://${controller}:9696",
    public_url   => "http://${controller}:9696",
    password     => $password
  }

  class { '::neutron':
    allow_overlapping_ips   => false,
    bind_host               => $bind_host,
    core_plugin             => 'ml2',
    dhcp_agent_notification => true,
    rabbit_user             => $user,
    rabbit_password         => $password,
    rabbit_host             => $controller,
    rabbit_port             => $rabbit_port
  }

  include ::neutron::client

  class { '::neutron::server':
    api_workers         => $::processorcount,
    auth_uri            => "http://${controller}:5000",
    auth_url            => "http://${controller}:35357",
    database_connection => "mysql+pymysql://${user}:${password}@${controller}/neutron?charset=utf8",
    password            => $password,
    rpc_workers         => $::processorcount,
    sync_db             => true
  }

  class { '::neutron::server::notifications':
    auth_url => "http://${controller}:35357",
    nova_url => "http://${controller}:8774/v2",
    password => $nova_password
  }

  class { '::neutron::plugins::ml2':
    type_drivers          => ['flat'],
    tenant_network_types  => [],
    mechanism_drivers     => ['linuxbridge'],
    flat_networks         => ['physnet0'],
  }

  class { '::neutron::agents::ml2::linuxbridge':
    firewall_driver             => 'neutron.agent.firewall.NoopFirewallDriver',
    local_ip                    => $::ipaddress,
    physical_interface_mappings => ['physnet0:eth0'],
  }

  # Provider network
  neutron_network { 'publicnet':
    shared                    => true,
    provider_network_type     => 'flat',
    provider_physical_network => 'physnet0',
  }

  # Provider subnet
  neutron_subnet { 'publicsubnet':
    cidr             => '172.19.4.0/22',
    gateway_ip       => '172.19.7.254',
    network_name     => 'publicnet',
    dns_nameservers  => ['172.19.7.253'],
    allocation_pools => ["start=172.19.4.10,end=172.19.7.250"],
  }
}
