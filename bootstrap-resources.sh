#!/bin/bash
echo "Provisioning test resources"
pushd /root
source openrc
ssh-keygen -f .ssh/id_rsa -t rsa -N ''
openstack keypair create --public-key .ssh/id_rsa.pub centos-cloud-key
net_id=$(openstack network list -f value |grep public |awk '{print $1}')
openstack server create --flavor medium --image 'CentOS 7' --nic net-id=${net_id} --key-name centos-cloud-key test-server1
openstack server create --flavor small --image 'CentOS 6' --nic net-id=${net_id} --key-name centos-cloud-key test-server2
openstack server create --flavor tiny --image 'Fedora 24' --nic net-id=${net_id} --key-name centos-cloud-key test-server3
popd
