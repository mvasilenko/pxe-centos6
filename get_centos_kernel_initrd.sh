#!/bin/bash

# list Ubuntu releases, download kernel & initrd for each release and place it under tftp dir

tftpboot="/var/lib/tftpboot"
centos_install_url="ftp://192.168.1.91/pub"
kickstart_url="ftp://192.168.1.91/pub"

which curl >/dev/null 2>&1
if [ $? -ne 0 ];then echo "curl command not found, please install it"; exit; fi

cat > $tftpboot/default.template.centos <<EOF
menu begin
menu title CentOS

label ..
menu exit

EOF

for release in 6 7
do
    for arch in i386 x86_64;do
    if [ $release == 7 ] &&  [ $arch == "i386" ];then continue;fi
        echo "release=$release arch=$arch"
        mkdir -p $tftpboot/centos/$release/$arch

# http://mirror.centos.org/centos-6/6/os/i386/images/pxeboot/vmlinuz

	cd $tftpboot/centos/$release/$arch && \
	    if [ ! -s vmlinuz ];then curl http://mirror.centos.org/centos-$release/$release/os/$arch/images/pxeboot/vmlinuz >vmlinuz;fi
	cd $tftpboot/centos/$release/$arch && \
	    if [ ! -s initrd.img ];then curl http://mirror.centos.org/centos-$release/$release/os/$arch/images/pxeboot/initrd.img >initrd.img;fi

# auto=true priority=critical vga=788 initrd=ubuntu-installer/amd64/initrd.gz preseed/url=tftp://192.168.1.91/ubuntu-16.04-preseed.cfg preseed/interactive=false

	echo "LABEL CentOS $release $arch 
	MENU LABEL CentOS $release $arch
	KERNEL centos/$release/$arch/linux
	APPEND initrd=centos/$release/$arch/initrd.img inst.repo=http://mirror.centos.org/centos-$release/$release/$arch ks=$centos_install_url/centos-$release-$arch.cfg  ksdevice=bootif
	">>$tftpboot/default.template.centos
    done
done

cat >> $tftpboot/default.template.centos <<EOF

menu end

EOF
