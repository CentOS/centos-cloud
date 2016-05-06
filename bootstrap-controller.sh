#!/bin/bash
# Helper script to repetitively test things quickly

bash baseline.sh
if [ $? -ne 0 ]; then
  echo 'Something broke in the baseline'
  exit 1
fi

yum -y install yum-plugin-priorities rubygems centos-release-openstack-mitaka
yum -y install puppet
gem install r10k

pushd /etc/puppet
PUPPETFILE=/root/centos-cloud/puppet/Puppetfile r10k puppetfile install -v
mv /root/centos-cloud/puppet/modules/centos_cloud modules/
echo "127.0.0.1 controller.openstack.ci.centos.org" >>/etc/hosts
puppet apply -e "include ::centos_cloud::controller" || exit 1
popd
