class centos_cloud::compute {
  include centos_cloud::server
  include centos_cloud::compute::nova
  include centos_cloud::compute::neutron

  file { '/etc/modprobe.d/kvm_intel.conf':
    content => "options kvm_intel nested=1\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  exec { 'load vhost_net module':
    command => '/usr/sbin/modprobe vhost_net',
    creates => '/etc/modprobe.d/vhost.conf'
  }
}
