class centos_cloud::controller::horizon (
  $allowed_hosts      = '*',
  $bind_host          = '0.0.0.0',
  $cache_server_ip    = '127.0.0.1',
  $neutron_options    = { enable_security_group => false },
  $secret_key         = 'horizon',
  $servername         = 'dashboard.openstack.ci.centos.org',
  $vhost_extra_params = { add_listen => false }
){
  class { '::horizon':
    allowed_hosts      => $allowed_hosts,
    bind_address       => $bind_host,
    cache_server_ip    => $cache_server_ip,
    neutron_options    => $neutron_options,
    secret_key         => $secret_key,
    servername         => $servername,
    vhost_extra_params => $vhost_extra_params
  }
}
