class centos_cloud::server {
  include ::centos_cloud::server::packages
  include ::centos_cloud::server::auth_file
  include ::ntp

  sysctl::value {
    'net.ipv4.tcp_keepalive_time':   value => '30';
    'net.ipv4.tcp_keepalive_intvl':  value => '1';
    'net.ipv4.tcp_keepalive_probes': value => '5';
  }
}
