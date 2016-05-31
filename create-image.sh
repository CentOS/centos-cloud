#!/bin/bash
# This script creates an image with built-in fixes and expectations for
# consumption in the ci.centos.org OpenStack environment.
#
# Requirements:
# yum -y install libguestfs-tools wget libvirt
# systemctl start libvirtd
#
# The image is created at /tmp/centos7.qcow2.
# Once the image has been downloaded and setup, it can be uploaded to OpenStack
# as follows:
#     source openrc
#     openstack image create --disk-format qcow2 --file /tmp/centos7.qcow2 centos7

echo "Downloading image..."
wget http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2 -O /tmp/centos7.qcow2

# Description of image customization:
# - Enable macros to ensure the image starts from a clean state
# - Disable ec2_metadata, it is not available so prevent cloud-init to try and look for it
# - Have cloud-init manage /etc/hosts so that the hostname/name of the VM resolves in /etc/hosts
# - Toggle fix for SSE 4.2 CPU flag issue (https://access.redhat.com/articles/2050743)
# - Have cloud-init setup and use the root user instead of 'centos'.

cat > /tmp/99_users.cfg << 'EOF'
disable_root: false
ssh_pwauth: false
chpasswd: { expire: false }
user: root
users:
  - name: root
    gecos: root
    inactive: false
    system: true
    lock_passwd: false
    no_create_home: true
    no_create_group: true
EOF

virt-sysprep --enable=ssh-hostkeys,udev-persistent-net,net-hwaddr,dhcp-client-state,dhcp-server-state,customize \
             --write '/etc/cloud/cloud.cfg.d/00_disable_ec2_metadata.cfg:disable_ec2_metadata: True' \
             --write '/etc/cloud/cloud.cfg.d/99_manage_etc_hosts.cfg:manage_etc_hosts: True' \
             --write '/etc/sysconfig/64bit_strstr_via_64bit_strstr_sse2_unaligned:# Fix for SSE 4.2 CPU flag https://access.redhat.com/articles/2050743' \
             --upload '/tmp/99_users.cfg:/etc/cloud/cloud.cfg.d/99_users.cfg' \
             -a /tmp/centos7.qcow2
