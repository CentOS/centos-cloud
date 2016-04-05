#!/bin/bash
# Helper script to repetitively test things quickly
# ci.centos.org nodes come with a pre-installed firewall
yum -y remove firewalld

yum -y install yum-plugin-priorities rubygems centos-release-openstack-mitaka
yum -y install puppet python-openstackclient
gem install r10k

pushd /etc/puppet
PUPPETFILE=/root/centos-cloud/puppet/Puppetfile r10k puppetfile install -v
mv /root/centos-cloud/puppet/modules/centos_cloud modules/
echo "${1} controller.openstack.ci.centos.org" >> /etc/hosts
puppet apply -e "include ::centos_cloud::compute" || exit 1
popd
