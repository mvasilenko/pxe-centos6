#!/bin/bash

# list xatka directory, and generate pxe menu, with per-host variable for further parsing in post-install.sh

tftpboot="/var/lib/tftpboot"
centos_install_url="http://ftp.colocall.net/pub/centos"
kickstart_url="ftp://192.168.1.91/xatka/ks-centos-6-i386-xatka.cfg"
hosts_dir="/var/ftp/xatka"
release=6
arch=i386

cat > $tftpboot/default.template.xatka <<EOF
menu begin
menu title XATKA

label ..
menu exit

EOF

host_list=`cd $hosts_dir && find . -maxdepth 1 -type d|sed 's/.[\/]*//'|sed 's/common[ ]*//'`
echo $host_list

for site in $host_list;do 
    site_upper=`echo $site|awk '{print toupper($0)}'`
    echo "LABEL $site_upper CentOS $release $arch
    MENU LABEL $site_upper CentOS $release $arch
    KERNEL centos/$release/$arch/vmlinuz
    APPEND initrd=centos/$release/$arch/initrd.img ks=$kickstart_url  ksdevice=bootif method=$centos_install_url/$release/os/$arch xatka_host=$site
    ">>$tftpboot/default.template.xatka
done

cat >> $tftpboot/default.template.xatka <<EOF

menu end

EOF
