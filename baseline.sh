#!/bin/bash
# This script will do the basic common stuff needed everywhere
if rpm -q NetworkManager; then
    service NetworkManager stop
    yum -y remove Network\*
    service network restart
fi

if rpm -q firewalld; then
    yum -y remove firewalld
fi

ping -c 3 8.8.8.8 > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo 'We lost network, exiting now'
  exit 1
fi

# Add own fqdn to hosts file
if ! grep -q "127.0.0.1 $(hostname -f)" /etc/hosts; then
    echo "127.0.0.1 $(hostname -f)" >>/etc/hosts
    echo "Added to hosts file: 127.0.0.1 $(hostname -f)"
fi

yum -y install yum-plugin-priorities rubygems centos-release-openstack-newton
yum -y install puppet python-openstackclient openstack-selinux
gem install r10k

cwd=$(cd `dirname $0` && pwd -P)
r10k puppetfile install --puppetfile ${cwd}/puppet/Puppetfile --moduledir /etc/puppet/modules -v
cp -a ${cwd}/puppet/modules/centos_cloud /etc/puppet/modules/
