---
title: "Use NVME SSD as storage volume instead of cache"
date: 2023-06-23T10:37:20+02:00
draft: false
tags: ['synology', 'nvme', 'storage']
---
## Create Partition
Login as root with SSH and type :
```bash
ls /dev/nvme*
```
You will see the /dev/nvme0n1 or /dev/nvme1n1 depend on which slot you install the SSD.
type:
```bash
fdisk -l /dev/nvme0n1
```
You wil see the disk information. ( if your SSD is at slot 2, use /dev/nvme1n1 instead)
```bash
Disk /dev/nvme0n1: 238.5 GiB, 256060514304 bytes, 500118192 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```
Now, create partition, type:
```bash
synopartition --part /dev/nvme0n1 12
```
and answer 'Y' to confirm
```bash
        Device   Sectors (Version8: SupportRaid)
 /dev/nvme0n11   4980480 (2431 MB)
 /dev/nvme0n12   4194304 (2048 MB)
Reserved size:    260352 ( 127 MB)
Primary data partition will be created.

WARNING: This action will erase all data on '/dev/nvme0n1' and repart it, are you sure to continue? [y/N]y
Cleaning all partitions...
Creating sys partitions...
Creating primary data partition...
Please remember to mdadm and mkfs new partitions.
```
it will create the partition that follows the DSM required layout.

Type:
```bash
 fdisk -l /dev/nvme0n1
```
You will see the partition layout is created
```bash
Disk /dev/nvme0n1: 238.5 GiB, 256060514304 bytes, 500118192 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xef61a3e4

Device         Boot   Start       End   Sectors  Size Id Type
/dev/nvme0n1p1         2048   4982527   4980480  2.4G fd Linux raid autodetect
/dev/nvme0n1p2      4982528   9176831   4194304    2G fd Linux raid autodetect
/dev/nvme0n1p3      9437184 500103449 490666266  234G fd Linux raid autodetect
```
## Create Basic Disk
For Basic Disk, it needs to create a single partition RAID1 device in order for DSM to recognize it. (as this is what DSM Storage Manager will do when creating a Basic Disk Volume)
Type:
```bash
cat /proc/mdstat
```
To see your current RAID setup
```bash
Personalities : [linear] [raid0] [raid1] [raid10] [raid6] [raid5] [raid4]
md2 : active raid1 sda3[0] sdb3[1]
      5855700544 blocks super 1.2 [2/2] [UU]

md3 : active raid1 sdc3[0] sdd3[1]
      9761614848 blocks super 1.2 [2/2] [UU]

md1 : active raid1 sda2[0] sdb2[1] sdc2[2] sdd2[3]
      2097088 blocks [4/4] [UUUU]

md0 : active raid1 sda1[0] sdb1[3] sdc1[1] sdd1[2]
      2489920 blocks [4/4] [UUUU]
```
AFAIK, md0 is system partition and md1 is system swap. You current volume/storage pool will start at md2.

To create your NVME Basic disk, type:
```bash
 mdadm --create /dev/md4 --level=1 --raid-devices=1 --force /dev/nvme0n1p3
```
(if md4 already exist, you should use next md number)
And answer "Y".
```bash
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md5 started.
```

## Create Filesystem
Type
```bash
mkfs.ext4 -F /dev/md5
```
This will use ext4.
```bash
mke2fs 1.42.6 (21-Sep-2012)
Filesystem label=1.42.6-23824
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
15335424 inodes, 61333024 blocks
25600 blocks (0.04%) reserved for the super user
First data block=0
Maximum filesystem blocks=2210398208
1872 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000, 7962624, 11239424, 20480000, 23887872

Allocating group tables: done
Writing inode tables: done
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done
```
If you want btrfs, type
```bash
mkfs.btrfs -f /dev/md5
```
After format complete , type
```bash
reboot
```
and after the machine bootup, you will see the Volume in DSM Storage Manager

![Synology Storage](/images/synologyvolume.jpg)

Source:
r/synology - [Guide] Use NVME SSD as storage volume instead of cache in DS918
and the Volume is ready for use.
https://www.reddit.com/r/synology/comments/a7o44l/guide_use_nvme_ssd_as_storage_volume_instead_of/