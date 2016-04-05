class centos_cloud::controller {
  include centos_cloud::server
  include centos_cloud::controller::rabbitmq
  include centos_cloud::controller::mysql
  include centos_cloud::controller::keystone
  include centos_cloud::controller::glance
  include centos_cloud::controller::neutron
  include centos_cloud::controller::nova
  include centos_cloud::controller::horizon
}
