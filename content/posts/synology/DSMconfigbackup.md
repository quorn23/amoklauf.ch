---
title: "DSM Config backup via script"
date: 2022-11-01T13:05:36+01:00
draft: false
tags: ['synology', 'DSM', 'backup']
---
Synology doesn't allow you to backup the DSM config in an automated way, besides via the Synology Account. This gets saved god knows who and is just "automated", without any possibility to set a schedule. I don't like this limited out of the box option, so here is a script i added to my CMS to push out to my Synos. Tested on DSM6 and DSM7 devices. In my case it uses a NFS Share, but should be easily adaptable to a CIFS share for example.

{{< tip title="PSA" >}}
SA: I keep my backup drives genearlly unmounted if not in use, as a small layer of extra security in case of File Encryption Malware and sorts*
{{< /tip >}}
The script will mount the backup share, checks it, then starts the backup and finally unmounts it again.  
```
#!/bin/bash

# Variables
NFS_SERVER="10.0.0.14"
NFS_SHARE="/volume1/backup_DSM_Configs"
MOUNT_POINT="/mnt/nfs"

TEST_FILE="$MOUNT_POINT/testfile"

# Check if the mount point directories exists, if not create them
if [ ! -d "$MOUNT_POINT" ]; then
    mkdir -p $MOUNT_POINT
fi

if [ ! -d "$MOUNT_POINT/$(hostname)" ]; then
    mkdir -p $MOUNT_POINT/$(hostname)
fi

# Mount the NFS share
mount -t nfs $NFS_SERVER:$NFS_SHARE $MOUNT_POINT

# Check if the NFS share is available
function check_mount {
    touch $TEST_FILE
    if [ -f "$TEST_FILE" ]; then
        rm $TEST_FILE
        return 0
    else
        return 1
    fi
}

# Check if the mount was successful
if check_mount; then
    echo "NFS share is mounted."
else
    echo "Mounting NFS share failed."
    exit 1
fi

# Execute your command here
synoconfbkp export --filepath=/mnt/nfs/synology/$(hostname)/$(date +%y%m%d%m%s)_$(hostname).dss && find /mnt/nfs/synology/$(hostname) -type f -mtime +180 -exec rm -f {} \;

# Unmount the NFS share
umount $MOUNT_POINT

    echo "NFS share is unmounted."

exit 0
```

edit `NFS_SERVER` `NFS_SHARE` `MOUNT_POINT` to your needs\
edit `-mtime +180` in case you want to change how many days the backups are kept, depending on the DSM version it's a rather small file, adapt to your needs.\
Add the scripts to your Task Scheduler in DSM, run as root and a schedule of your choice.
