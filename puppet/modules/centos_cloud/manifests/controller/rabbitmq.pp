class centos_cloud::controller::rabbitmq {
  class { '::rabbitmq':
    delete_guest_user => true,
    repos_ensure      => false,
    package_provider  => 'yum'
  }

  rabbitmq_vhost { '/':
    provider => 'rabbitmqctl',
    require  => Class['::rabbitmq'],
  }
}
