class centos_cloud::controller::glance (
  $allowed_hosts = "172.22.6.0/23",
  $backend       = 'file',
  $bind_host     = '0.0.0.0',
  $controller    = 'controller.openstack.ci.centos.org',
  $password      = 'glance',
  $rabbit_port   = '5672',
  $stores        = ['http', 'file'],
  $user          = 'glance'
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

  class { '::glance::api':
    auth_uri            => "http://${controller}:5000",
    bind_host           => $bind_host,
    database_connection => "mysql+pymysql://${user}:${password}@${controller}/glance?charset=utf8",
    default_store       => $backend,
    identity_uri        => "http://${controller}:35357",
    keystone_password   => $password,
    registry_host       => $controller,
    stores              => $stores,
    workers             => $::processorcount
  }

  class { '::glance::registry':
    auth_uri            => "http://${controller}:5000",
    bind_host           => $bind_host,
    database_connection => "mysql+pymysql://${user}:${password}@${controller}/glance?charset=utf8",
    identity_uri        => "http://${controller}:35357",
    keystone_password   => $password,
    workers             => $::processorcount
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
