class centos_cloud::controller::glance (
  $allowed_hosts     = '172.22.6.%',
  $backend           = 'file',
  $bind_host         = '0.0.0.0',
  $controller        = 'controller.openstack.ci.centos.org',
  $memcached_servers = ['127.0.0.1:11211'],
  $password          = 'glance',
  $rabbit_port       = '5672',
  $stores            = ['http', 'file'],
  $user              = 'glance',
  $workers           = '8',
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

  class { '::glance::db::mysql':
    allowed_hosts => [$controller, $allowed_hosts],
    password      => $password,
    user          => $user
  }

  include ::glance
  include ::glance::client
  include ::glance::backend::file

  class { '::glance::keystone::auth':
    admin_url    => "http://${controller}:9292",
    internal_url => "http://${controller}:9292",
    public_url   => "http://${controller}:9292",
    password     => $password
  }

  class { '::glance::api::authtoken':
    password            => $password,
    user_domain_name    => 'Default',
    project_domain_name => 'Default',
    auth_url            => "http://${controller}:35357",
    auth_uri            => "http://${controller}:5000",
    memcached_servers   => $memcached_servers,
  }

  class { '::glance::api':
    bind_host           => $bind_host,
    database_connection => "mysql+pymysql://${user}:${password}@${controller}/glance?charset=utf8",
    default_store       => $backend,
    registry_host       => $controller,
    stores              => $stores,
    workers             => $workers
  }

  class { '::glance::registry::authtoken':
    password            => $password,
    user_domain_name    => 'Default',
    project_domain_name => 'Default',
    auth_url            => "http://${controller}:35357",
    auth_uri            => "http://${controller}:5000",
    memcached_servers   => $memcached_servers,
  }

  class { '::glance::registry':
    bind_host           => $bind_host,
    database_connection => "mysql+pymysql://${user}:${password}@${controller}/glance?charset=utf8",
    workers             => $workers
  }

  class { '::glance::notify::rabbitmq':
    rabbit_userid       => $user,
    rabbit_password     => $password,
    rabbit_host         => $controller,
    rabbit_port         => $rabbit_port,
    rabbit_use_ssl      => false,
    notification_driver => 'messagingv2'
  }
}
