class centos_cloud::server::packages {
  package { [
    'bash-completion',
    'deltarpm',
    'libguestfs-tools',
    'libselinux-python',
    'lsof',
    'net-tools',
    'policycoreutils-python',
    'psmisc',
    'redhat-lsb-core',
    'screen',
    'sysfsutils',
    'sysstat',
    'tcpdump',
    'wget',
    'mtr',
    'nmap'
  ]:
    ensure => 'latest'
  }
}
