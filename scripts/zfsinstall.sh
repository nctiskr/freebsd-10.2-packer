#!/bin/sh

echo '==> Installing FreeBSD with ZFS root...'
mount_cd9660 /dev/cd0 /cdrom

echo '==> VirtualBox detected, installing FreeBSD on ada0.'
# zfsinstall -d ada0 -s 1G -u /cdrom/10.2-RELEASE-amd64
zfsinstall -d /dev/ada0 -u /cdrom/10.2-RELEASE-amd64 -p zroot -s 1G

echo '==> Preparing machine for first boot via setup script...'
mount -t devfs devfs /mnt/dev
cat update.sh | chroot /mnt sh -
