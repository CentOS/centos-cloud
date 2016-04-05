#!/bin/bash
echo "Provisioning test resources"
pushd /root
source openrc
ssh-keygen -f .ssh/id_rsa -t rsa -N ''
openstack keypair create --public-key .ssh/id_rsa.pub centos-cloud-key
wget -q http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2 -O /tmp/centos7.qcow2
virt-sysprep --enable=ssh-hostkeys,udev-persistent-net,net-hwaddr,dhcp-client-state,dhcp-server-state,customize \
             --write '/etc/cloud/cloud.cfg.d/00_disable_ec2_metadata.cfg:disable_ec2_metadata: True' \
             --write '/etc/cloud/cloud.cfg.d/99_manage_etc_hosts.cfg:manage_etc_hosts: True' \
             --root-password password:root \
             -a /tmp/centos7.qcow2
openstack image create --disk-format qcow2 --file /tmp/centos7.qcow2 centos7
net_id=$(openstack network list -f value |awk '{print $1}')
openstack server create --flavor m1.small --image centos7 --nic net-id=${net_id} --key-name centos-cloud-key test-server
popd
