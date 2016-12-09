#!/bin/bash
# Install needed packages
yum -y install dhcp tftp tftp-server syslinux vsftpd xinetd openssl
# Copy dhcp config
cp -v etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf
# Activate tftp
sed -i '/	disable			= yes/c\	disable			= no' /etc/xinetd.d/tftp
# Copy system PXE files
cp -v /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot
cp -v /usr/share/syslinux/menu.c32 /var/lib/tftpboot
cp -v /usr/share/syslinux/memdisk /var/lib/tftpboot
cp -v /usr/share/syslinux/mboot.c32 /var/lib/tftpboot
cp -v /usr/share/syslinux/chain.c32 /var/lib/tftpboot
# Directory for PXE menu file
mkdir -p /var/lib/tftpboot/pxelinux.cfg
# Directory for kernel & initrd
mkdir -p /var/lib/tftpboot/networkboot
# Custom PXE menu file
cp -v var/lib/tftpboot/pxelinux.cfg/* /var/lib/tftpboot/pxelinux.cfg/
mkdir -p /var/ftp/pub
# Get CentOS image
wget http://ftp.colocall.net/pub/centos/6/isos/i386/CentOS-6.8-i386-netinstall.iso
# Mount it
mount -o loop CentOS-6.8-i386-netinstall.iso /mnt
# Copy to local ftp dir
cd /mnt && cp -av * /var/ftp/pub
# Copy kernel & initrd needed for network boot
cp /mnt/images/pxeboot/vmlinuz /var/lib/tftpboot/networkboot/
cp /mnt/images/pxeboot/initrd.img /var/lib/tftpboot/networkboot/
umount /mnt

# root password
ROOTPASS=`openssl passwd -1 Pxe@123#`
# Copy kickstart files
cp var/ftp/pub/* /var/ftp/pub/
# change password
sed -i '/rootpw Pxe@123#/\crootpw --iscrypted $ROOTPASS' /var/ftp/pub/centos6-i386-mvts.cfg
