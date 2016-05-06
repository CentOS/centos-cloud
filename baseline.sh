#!/bin/bash
# Helper script to repetitively test things quickly
# this script will do the basic common stuff needed everywhere

yum -y remove firewalld
service NetworkManager stop
yum -y remove Network\*
service network restart

ping -c 1 8.8.8.8 > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo 'we lost network, exiting now'
  exit 1
fi
