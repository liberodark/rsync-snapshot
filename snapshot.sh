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
snapshots="1"
lock="/tmp/rsync-snapshot.lock"
remove() { find "$dest" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | head -n -$snapshots | xargs rm -r; }

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
    --exclude "/var/log/*" \
    --exclude "/var/cache/pacman/pkg/*" \
    --exclude "/var/cache/apt/archives/*" \
    --exclude "/var/cache/yum/*" \
    --exclude "/var/tmp/pamac-build-pc/*" \
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
