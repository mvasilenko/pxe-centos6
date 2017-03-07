#!/bin/sh

# list Ubuntu releases, download kernel & initrd for each release and place it under tftp dir

tftpboot="/var/lib/tftpboot"
preseed_url="tftp://192.168.1.91/ubuntu-preseed.cfg"

which curl >/dev/null 2>&1
if [ $? -ne 0 ];then echo "curl command not found, please install it"; exit; fi

curl -s http://releases.ubuntu.com > /tmp/releases-ubuntu-tmp.txt
cdimage_pos=`grep href /tmp/releases-ubuntu-tmp.txt|grep -n -o cdimage|head -n1|cut -d":" -f1`
cdimage_pos=$((cdimage_pos-1))

releases_list=`grep href /tmp/releases-ubuntu-tmp.txt|head -n $cdimage_pos|sort -n -k1 -r|cut -d'"' -f2|cut -d"/" -f1|uniq`

cat > $tftpboot/default.template.ubuntu <<EOF
menu begin
menu title Ubuntu

label ..
menu exit

EOF
for release in $releases_list
do
    release_descr=`grep href /tmp/releases-ubuntu-tmp.txt|head -n $cdimage_pos|grep $release|cut -d">" -f3|cut -d"<" -f1|head -n1`
    iso=`curl -s http://releases.ubuntu.com/$release/|grep server|grep "iso<"|grep i386|cut -d">" -f3|cut -d"<" -f1`
    for arch in amd64 #i386
    do
    echo "release=$release description=$release_descr arch=$arch"
    mkdir -p $tftpboot/ubuntu/$release/$arch

# http://archive.ubuntu.com/ubuntu/dists/yakkety-updates/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/linux

	cd $tftpboot/ubuntu/$release/$arch && \
	    if [ ! -s linux ];then curl http://archive.ubuntu.com/ubuntu/dists/$release-updates/main/installer-$arch/current/images/netboot/ubuntu-installer/$arch/linux >linux;fi
	cd $tftpboot/ubuntu/$release/$arch && \
	    if [ ! -s initrd.gz ];then curl http://archive.ubuntu.com/ubuntu/dists/$release-updates/main/installer-$arch/current/images/netboot/ubuntu-installer/$arch/initrd.gz >initrd.gz;fi

# auto=true priority=critical vga=788 initrd=ubuntu-installer/amd64/initrd.gz preseed/url=tftp://192.168.1.91/ubuntu-16.04-preseed.cfg preseed/interactive=false

	echo "LABEL $release_descr $arch 
	MENU LABEL $release_descr $arch
	KERNEL ubuntu/$release/$arch/linux
	APPEND auto=true initrd=ubuntu/$release/$arch/initrd.gz preseed/url=$preseed_url preseed/interactive=false
	">>$tftpboot/default.template.ubuntu
    done
done

cat >> $tftpboot/default.template.ubuntu <<EOF

menu end

EOF
