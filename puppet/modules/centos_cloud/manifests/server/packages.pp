class centos_cloud::server::packages {
  package { [
    'bash-completion',
    'deltarpm',
    'libguestfs-tools',
    'libselinux-python',
    'lsof',
    'net-tools',
    'openstack-selinux',
    'policycoreutils-python',
    'psmisc',
    'redhat-lsb-core',
    'screen',
    'sysfsutils',
    'sysstat',
    'tcpdump',
    'wget'
  ]:
    ensure => 'latest'
  }
}
