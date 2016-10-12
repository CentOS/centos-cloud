class centos_cloud::compute::neutron (
  $controller       = 'controller.openstack.ci.centos.org',
  $memcache_servers = ['127.0.0.1:11211'],
  $bind_host        = '0.0.0.0',
  $rabbit_port      = '5672',
  $user             = 'neutron',
  $password         = 'neutron',
) {
    class { '::neutron':
    allow_overlapping_ips   => false,
    bind_host               => $bind_host,
    core_plugin             => 'ml2',
    dhcp_agent_notification => true,
    memcache_servers        => $memcache_servers,
    rabbit_user             => $user,
    rabbit_password         => $password,
    rabbit_host             => $controller,
    rabbit_port             => $rabbit_port
  }

  class { '::neutron::plugins::ml2':
    type_drivers         => ['flat'],
    tenant_network_types => [],
    mechanism_drivers    => ['linuxbridge'],
    flat_networks        => ['physnet0'],
  }

  class { '::neutron::agents::ml2::linuxbridge':
    firewall_driver             => 'neutron.agent.firewall.NoopFirewallDriver',
    local_ip                    => $::ipaddress,
    physical_interface_mappings => ['physnet0:eth0'],
  }

  class { '::neutron::agents::dhcp':
    interface_driver => 'neutron.agent.linux.interface.BridgeInterfaceDriver',
  }
}
