#!/bin/sh

# Packages which are pre-installed
INSTALLED_PACKAGES="virtualbox-ose-additions bash sudo ca_root_nss"

# Configuration files
HOSTS="https://raw.github.com/nctiskr/freebsd-10.2-packer/master/etc/hosts"
MAKE_CONF="https://raw.github.com/nctiskr/freebsd-10.2-packer/master/etc/make.conf"
LOADER_CONF="https://raw.github.com/nctiskr/freebsd-10.2-packer/master/boot/loader.conf"
RC_CONF="https://raw.github.com/nctiskr/freebsd-10.2-packer/master/etc/rc.conf"
RESOLV_CONF="https://raw.github.com/nctiskr/freebsd-10.2-packer/master/etc/resolv.conf"

# Private key of Vagrant (you probable don't want to change this)
VAGRANT_PRIVATE_KEY="https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub"

echo '==> Make network accessible...'
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
echo 'nameserver 8.8.4.4' >> /etc/resolv.conf

echo '==> Configuring system...'
sysrc hostname=vagrant
sysrc ifconfig_em0=DHCP

echo '==> Configuring SSH...'
sysrc sshd_enable=YES
sed -i '' -e 's/#PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i '' -e 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

echo '==> Setting up pkg...'
if [ ! -f /usr/local/sbin/pkg ]; then
    env ASSUME_ALWAYS_YES=yes pkg bootstrap
fi

echo '==> Update pkg...'
pkg update
pkg upgrade -y

echo '==> Install required packages...'
for p in $INSTALLED_PACKAGES; do
    pkg install -y "$p"
done

echo '==> Create the vagrant user...'
pw useradd -n vagrant -s /usr/local/bin/bash -m -G wheel -h 0 <<EOP
vagrant
EOP

echo '==> Enable sudo for this user...'
echo "%vagrant ALL=(ALL) NOPASSWD: ALL" >> /usr/local/etc/sudoers

echo '==> Install authorized ssh keys...'
mkdir /home/vagrant/.ssh
fetch -o /home/vagrant/.ssh/authorized_keys $VAGRANT_PRIVATE_KEY
chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
chown vagrant:vagrant /home/vagrant/.ssh
chmod -R go-rwx /home/vagrant/.ssh

# Fetching Configuration Files
echo '==> Fetching hosts file...'
fetch -o /etc/make.conf $HOSTS

echo '==> Fetching make.conf...'
fetch -o /etc/make.conf $MAKE_CONF

echo '==> Fetching loader.conf...'
fetch -o /boot/loader.conf $LOADER_CONF

echo '==> Fetching rc.conf...'
fetch -o /etc/rc.conf $RC_CONF

echo '==> Fetching resolv.conf...'
fetch -o /etc/resolv.conf $RESOLV_CONF

echo '==> Clean up installed packages...'
pkg clean -a -y

echo '==> Remove the history...'
cat /dev/null > /root/.history

echo '==> Try to make it even smaller...'
dd if=/dev/zero of=/tmp/ZEROES bs=1M

echo '==> Empty out tmp directory...'
rm -rf /tmp/*

echo '==> Done.'
