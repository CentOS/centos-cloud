class centos_cloud::compute::nova (
  $controller       = 'controller.openstack.ci.centos.org',
  $rabbit_port      = '5672',
  $user             = 'nova',
  $user_api         = 'nova_api',
  $password         = 'nova',
  $password_api     = 'nova_api',
  $neutron_password = 'neutron'
) {

  class { '::nova':
    api_database_connection => "mysql+pymysql://${user_api}:${password_api}@${controller}/nova_api?charset=utf8",
    database_connection     => "mysql+pymysql://${user}:${password}@${controller}/nova?charset=utf8",
    glance_api_servers      => "http://${controller}:9292",
    notification_driver     => 'messagingv2',
    notify_on_state_change  => 'vm_and_task_state',
    rabbit_host             => $controller,
    rabbit_password         => $password,
    rabbit_port             => $rabbit_port,
    rabbit_userid           => $user,
    rabbit_use_ssl          => false
  }

  class { '::nova::compute':
    force_config_drive          => true,
    instance_usage_audit        => true,
    instance_usage_audit_period => 'hour',
    vnc_enabled                 => true
  }

  class { '::nova::compute::libvirt':
    libvirt_virt_type => 'qemu',
    migration_support => true,
    vncserver_listen  => '0.0.0.0',
  }

  class { '::nova::compute::neutron':
    libvirt_vif_driver => 'nova.virt.libvirt.vif.LibvirtGenericVIFDriver',
  }

  class { '::nova::network::neutron':
    firewall_driver    => 'nova.virt.firewall.NoopFirewallDriver',
    neutron_auth_url   => "http://${controller}:35357/v3",
    neutron_url        => "http://${controller}:9696",
    neutron_password   => $neutron_password,
  }

  include ::nova::vncproxy
  include ::nova::consoleauth
}
