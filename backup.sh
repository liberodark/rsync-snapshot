#!/bin/bash
#
# About: Rsync Snapshots
# Author: liberodark
# Thanks : erdnaxeli
# License: GNU GPLv3

version="0.1.0"

echo "Welcome on Rsync Snapshots Script $version"

#=================================================
# CHECK ROOT
#=================================================

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

#=================================================
# RETRIEVE ARGUMENTS FROM THE MANIFEST AND VAR
#=================================================

date=$(date +%Y.%m.%d_%H-%M-%S)
dest="/root/backup/"
snapshots="3"
lock="/tmp/rsync-snapshot.lock"
remove() { ls "$dest" | head -n -$snapshots | xargs rm -r; }

# Create Folder
mkdir -p "$dest""$date"

# Remove Old Backup
pushd "$dest" || exit
"remove"
popd || exit

exec 9>"${lock}"
flock -n 9 || exit

# Backup
rsync -aPh \
    --exclude "/dev/*" \
    --exclude "/proc/*" \
    --exclude "/sys/*" \
    --exclude "/tmp/*" \
    --exclude "/run/*" \
    --exclude "/mnt/*" \
    --exclude "/media/*" \
    --exclude "/vmlinuz" \
    --exclude "/initrd.img" \
    --exclude "/var/log/?*.log" \
    --exclude "/var/log/*/*.log" \
    --exclude "/var/log/lastlog" \
    --exclude "/var/run/?*.pid" \
    --exclude "/etc/fstab" \
    --exclude "/etc/mtab" \
    --exclude "/etc/selinux/*" \
    --exclude "/etc/network/interface" \
    --exclude "/etc/sysconfig/network-scripts/*" \
    --exclude "/lib/modules/*" \
    --exclude "/usr/lib/modules/*" \
    --exclude "/lib/firmware/*" \
    --exclude "/usr/lib/firmware/*" \
    --exclude "/etc/ld.so.conf.d/kernel-*" \
    --exclude "/boot/*" \
    --exclude "/etc/grub.d/*" \
    --exclude "/usr/lib/grub/*" \
    --exclude "/etc/cloud/*" \
    --exclude "/var/lib/cloud/*" \
    --exclude "/etc/ssh/*" \
    --exclude "/etc/yum.conf" \
    --exclude "/etc/yum/*" \
    --exclude "/etc/yum.repos.d/*" \
    --exclude "/var/cache/pacman/pkg/*" \
    --exclude "/var/cache/apt/archives/*" \
    --exclude "/var/cache/yum/*" \
    --exclude "/var/tmp/?*" \
    --exclude "/var/lib/aurbuild/*" \
    --exclude "/var/lib/docker/*" \
    --exclude "/root/.cache/*" \
    --exclude "/lost+found" \
    --exclude "/root/backup/*" \
    --exclude "/home/*/.cache/*" \
    --exclude "/home/*/.local/share/Trash/*" \
    --exclude "/home/*/.thumbnails/*" \
    --exclude "/home/*/.steam/*" \
    --exclude "/home/*/GOG\ Games/*" \
    /* "$dest""$date"

pushd /root/backup/ || exit
tar -czvf backup-"$date".tar.gz "$date"
popd || exit
