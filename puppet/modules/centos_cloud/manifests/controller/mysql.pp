class centos_cloud::controller::mysql {

  file { '/etc/systemd/system/mariadb.service.d/':
    ensure => directory
  }->
  file { '/etc/systemd/system/mariadb.service.d/limits.conf':
    ensure => present,
    source => "puppet:///modules/${module_name}/limits.conf",
    notify => [ Exec['Reload systemctl'], Service['mysqld'] ]
  }

  exec { 'Reload sytemctl':
    command     => "/usr/bin/systemctl daemon-reload",
    refreshonly => true
  }

  class { '::mysql::server':
    override_options => {
      'mysqld' => {
        'bind-address'    => '0.0.0.0',
        'max_connections' => '512',
      }
    }
  }
}
