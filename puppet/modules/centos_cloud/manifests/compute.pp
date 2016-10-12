class centos_cloud::compute {
  include centos_cloud::server
  include centos_cloud::compute::nova
  include centos_cloud::compute::neutron

  include ::kmod
  kmod::load { 'kvm_intel': }
  kmod::option { 'kvm_intel':
    option => 'nested',
    value  => '1'
  }

  kmod::load { 'vhost_net': }
}
