wget http://archive.ubuntu.com/ubuntu/ubuntu/dists/xenial/main/installer-amd64/current/images/netboot/netboot.tar.gz -O ubuntu-16.04-netboot.tar.gz
mkdir ubuntu-16.04-netboot
tar zxf ubuntu-16.04-netboot.tar.gz -C ubuntu-16.04-netboot
sudo cp -a ubuntu-16.04-netboot/ubuntu-installer /var/lib/tftpboot
