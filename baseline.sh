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

yum -y install yum-plugin-priorities rubygems centos-release-openstack-mitaka
yum -y install puppet python-openstackclient
gem install r10k

pushd /etc/puppet
PUPPETFILE=/root/centos-cloud/puppet/Puppetfile r10k puppetfile install -v
cp -a /root/centos-cloud/puppet/modules/centos_cloud modules/
popd
