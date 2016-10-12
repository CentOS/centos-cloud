class centos_cloud::controller::nova (
  $allowed_hosts     = '172.22.6.0/23',
  $bind_host         = '0.0.0.0',
  $controller        = 'controller.openstack.ci.centos.org',
  $memcached_servers = ['127.0.0.1:11211'],
  $password          = 'nova',
  $password_api      = 'nova_api',
  $rabbit_port       = '5672',
  $user              = 'nova',
  $user_api          = 'nova_api',
  $neutron_password  = 'neutron',
  $workers           = '8',
  $threads           = '1'
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

  class { '::nova::db::mysql':
    allowed_hosts => [$controller, $allowed_hosts],
    password      => $password,
    user          => $user
  }

  class { '::nova::db::mysql_api':
    allowed_hosts => [$controller, $allowed_hosts],
    password      => $password_api,
    user          => $user_api
  }

  class { '::nova::keystone::auth':
    admin_url    => "http://${controller}:8774/v2/%(tenant_id)s",
    internal_url => "http://${controller}:8774/v2/%(tenant_id)s",
    public_url   => "http://${controller}:8774/v2/%(tenant_id)s",
    password     => $password
  }

  class { '::nova::keystone::authtoken':
    password            => $password,
    user_domain_name    => 'Default',
    project_domain_name => 'Default',
    auth_url            => "http://${controller}:35357",
    auth_uri            => "http://${controller}:5000",
    memcached_servers   => $memcached_servers,
  }

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

  class { '::nova::api':
    api_bind_address      => $bind_host,
    enabled_apis          => ['osapi_compute'],
    service_name          => 'httpd',
    sync_db_api           => true,
    osapi_compute_workers => $workers,
    install_cinder_client => false
  }

  include ::apache
  class { '::nova::wsgi::apache':
    bind_host  => $bind_host,
    servername => $controller,
    ssl        => false,
    workers    => $workers,
    threads    => $threads
  }

  class { '::nova::network::neutron':
    firewall_driver  => 'nova.virt.firewall.NoopFirewallDriver',
    neutron_auth_url => "http://${controller}:35357/v3",
    neutron_url      => "http://${controller}:9696",
    neutron_password => $neutron_password,
  }

  include ::nova::client
  class { '::nova::conductor':
    workers => $workers,
  }
  include ::nova::cron::archive_deleted_rows
  include ::nova::scheduler
  include ::nova::scheduler::filter
}
