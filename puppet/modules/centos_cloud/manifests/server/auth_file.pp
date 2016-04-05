class centos_cloud::server::auth_file (
  $controller = "controller.openstack.ci.centos.org",
  $password = "keystone"
){
  class { '::openstack_extras::auth_file':
    auth_url       => "http://${controller}:5000/v3/",
    password       => $password,
    project_domain => 'default',
    user_domain    => 'default'
  }
}
