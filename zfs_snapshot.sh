#!/bin/bash
#
# About: Rsync Snapshots
# Author: liberodark
# Thanks : 
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
dest="local-share"
snapshots="3"
lock="/tmp/zfs-snapshot.lock"
remove=$(zfs list -t snapshot | head -n -"${snapshots}" | grep "${dest}" | awk '{print $1}')

# Remove Old Snapshot
if [ -z "${remove}" ]; then
    echo "No Old Snapshot"
    else
    echo "Remove Old Snapshot"
    zfs destroy "${remove}"
fi

exec 9>"${lock}"
flock -n 9 || exit

# Backup
zfs snapshot "${dest}"@"${date}"
