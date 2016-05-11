class centos_cloud::server::auth_file (
  $controller = "controller.openstack.ci.centos.org",
  $password = "keystone",
  $path = '/root/openrc'
){
  class { '::openstack_extras::auth_file':
    auth_url       => "http://${controller}:5000/v3/",
    password       => $password,
    path           => $path,
    project_domain => 'default',
    user_domain    => 'default'
  } ->

  exec { 'Setup openstackclient bash completion':
    command => "/usr/bin/openstack complete >> ${path}",
    unless  => "/usr/bin/grep -q '_openstack()' ${path}"
  }
}
