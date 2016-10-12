#!/bin/bash
echo "Provisioning test resources"
source /root/openrc

# Ensure we have a ssh key configured
mkdir -p /root/.ssh
if [ ! -f /root/.ssh/id_rsa ]; then
    ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
fi
if ! grep -q centos-cloud-key <<<"$(openstack keypair list -f value)"; then
    openstack keypair create --public-key /root/.ssh/id_rsa.pub centos-cloud-key
fi

net_id=$(openstack network list -f value |grep public |awk '{print $1}')
openstack server create --flavor medium --image 'CentOS 7' --nic net-id=${net_id} --key-name centos-cloud-key test-server1
openstack server create --flavor small --image 'CentOS 6' --nic net-id=${net_id} --key-name centos-cloud-key test-server2
openstack server create --flavor tiny --image 'Fedora 24' --nic net-id=${net_id} --key-name centos-cloud-key test-server3
openstack server list