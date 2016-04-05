class centos_cloud::controller::mysql {
  class { '::mysql::server':
    override_options => {
      'mysqld' => {
        'bind-address'    => '0.0.0.0',
        'max_connections' => '512',
      }
    }
  }
}
