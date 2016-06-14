class centos_cloud::controller::keystone (
  $allowed_hosts          = "172.22.6.0/23",
  $bind_host              = '0.0.0.0',
  $controller             = 'controller.openstack.ci.centos.org',
  $password               = 'keystone',
  $user                   = 'keystone',
  $token_provider         = 'fernet',
  $enable_fernet_setup    = true,
) {

  include ::keystone::client

  class { '::keystone::db::mysql':
    allowed_hosts => [$controller, $allowed_hosts],
    password      => $password,
    user          => $user
  }

  class { '::keystone':
    admin_bind_host        => $bind_host,
    admin_token            => $password,
    database_connection    => "mysql+pymysql://${user}:${password}@${controller}/keystone",
    enabled                => true,
    public_bind_host       => $bind_host,
    service_name           => 'httpd',
    token_provider         => $token_provider,
    enable_fernet_setup    => $enable_fernet_setup
  }

  # Remove me when this is merged, built and released:
  # https://review.rdoproject.org/r/#/c/1144/
  file { '/var/log/keystone':
    ensure  => directory,
    owner   => 'keystone',
    group   => 'keystone',
    mode    => '0750',
    before  => Exec['keystone-manage db_sync'],
    require => Package['keystone']
  }->
  file { '/var/log/keystone/keystone.log':
    ensure  => file,
    owner   => 'root',
    group   => 'keystone',
    mode    => '0660',
    before  => Exec['keystone-manage db_sync'],
    require => Package['keystone']
  }

  include ::apache
  class { '::keystone::wsgi::apache':
    admin_bind_host => $bind_host,
    bind_host       => $bind_host,
    servername      => $controller,
    ssl             => false,
    workers         => $::processorcount
  }

  class { '::keystone::roles::admin':
    email    => 'ci@centos.org',
    password => $password
  }

  class { '::keystone::endpoint':
    admin_url    => "http://${controller}:35357",
    internal_url => "http://${controller}:5000",
    public_url   => "http://${controller}:5000"
  }

  include ::keystone::disable_admin_token_auth

  keystone_role { '_member_':
    ensure => present
  }
}
