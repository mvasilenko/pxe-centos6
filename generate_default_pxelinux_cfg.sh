#!/bin/bash
dir="/var/lib/tftpboot"
cat $dir/default.template.begin $dir/default.template.ubuntu $dir/default.template.centos $dir/default.template.end > $dir/default
cat $dir/default >$dir/pxelinux.cfg/default

