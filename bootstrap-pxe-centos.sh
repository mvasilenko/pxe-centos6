#!/bin/bash
# default root password is Pxe@123#
ROOTPASS=`openssl passwd -1 Pxe@123#`
DOWNLOAD_CENTOS_IMAGE=false
# Install needed packages
yum -y install dhcp tftp tftp-server syslinux vsftpd xinetd openssl wget
# Copy dhcp config
cp -v etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf
# Activate tftp
sed -i 's/disable[ \t]*=[ \t]*yes/disable\t\t\t= no/g' /etc/xinetd.d/tftp
# Copy system PXE files
cp -v /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot
cp -v /usr/share/syslinux/menu.c32 /var/lib/tftpboot
cp -v /usr/share/syslinux/memdisk /var/lib/tftpboot
cp -v /usr/share/syslinux/mboot.c32 /var/lib/tftpboot
cp -v /usr/share/syslinux/chain.c32 /var/lib/tftpboot
# Directory for PXE menu file
mkdir -p /var/lib/tftpboot/pxelinux.cfg
# Custom PXE menu file
cp -v var/lib/tftpboot/* /var/lib/tftpboot
cp -v var/lib/tftpboot/pxelinux.cfg/* /var/lib/tftpboot/pxelinux.cfg
# Check Centos image existence
if [ ! -d /var/ftp/pub/centos/6/i386 ] && [ "$DOWNLOAD_CENTOS_IMAGE" = true ];then
    echo TRUE
    exit
    # Get CentOS image
    if [ ! -s /tmp/CentOS-6.8-i386-minimal.iso ]; then
	wget -O /tmp/CentOS-6.8-i386-minimal.iso http://ftp.colocall.net/pub/centos/6/isos/i386/CentOS-6.8-i386-minimal.iso
    fi
    if [ ! -s /tmp/CentOS-6.8-i386-netinstall.iso ]; then
	wget -O /tmp/CentOS-6.8-i386-netinstall.iso http://ftp.colocall.net/pub/centos/6/isos/i386/CentOS-6.8-i386-netinstall.iso
    fi
    # Mount netinstall
    mount -o loop /tmp/CentOS-6.8-i386-netinstall.iso /mnt
    # Copy to local ftp dir
    mkdir -p /var/ftp/pub/centos/6/i386
    cd /mnt && cp -av * /var/ftp/pub/centos/6/i386

    # Copy kernel & initrd needed for network boot
    mkdir -p /var/lib/tftpboot/centos/6/i386
    cp /mnt/images/pxeboot/vmlinuz /var/lib/tftpboot/centos/6/i386/
    cp /mnt/images/pxeboot/initrd.img /var/lib/tftpboot/centos/6/i386/
    umount /mnt

    # Mount minimal install
    mount -o loop /tmp/CentOS-6.8-i386-minimal.iso /mnt
    # Copy to local ftp dir
    mkdir -p /var/ftp/pub/centos/6/i386
    cd /mnt && cp -av * /var/ftp/pub/centos/6/i386
    umount /mnt

fi

# Copy kickstart files
pwd
cp var/ftp/pub/* /var/ftp/pub
# change password at kickstart file
sed -i 's:rootpw Pxe123:rootpw --iscrypted '"$ROOTPASS"':g' /var/ftp/pub/ks-centos.cfg

# Start services
service xinetd restart
service dhcpd restart
service vsftpd restart

# TODO - modify iptables rules to open specific ports
service iptables save
iptables -I INPUT -p udp --dport 67:68 -j ACCEPT
iptables -I INPUT -p tcp -m state --state NEW --dport 21 -j ACCEPT

# download CentOS kernel & initrd
./get_centos_kernel_initrd.sh
# download Ubuntu kernel & initrd
./get_ubuntu_kernel_initrd.sh
# generate pxe boot menu
./generate_default_pxelinux_cfg.sh
