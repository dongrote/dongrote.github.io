---
date: 2024-11-14 09:31:39 -0500
title: How to Resize a Virtual Machine Disk
author: Don Grote
layout: post
---

This one is for me, but if anybody else benefits from it then good for you (sincerely).

Whenever I resize a virtual machine (VM) disk on my [proxmox](https://www.proxmox.com) server
I always forget how to resize the disk inside the VM to enable the guest operating
system (OS) to utilize it.

This assumes that the disk being resized was setup as an LVM (Logical Volume Manager) partition.
All commands assume `root` privileges.

## Resize the Partition

There isn't really a "resize" operation, per se.
Rather, we delete existing partitions and recreate them using the newly allocated space.

```sh
fdisk /dev/sda
> d  # delete a partition
> 5  # delete the fifth (i.e., first extended) partition
> d  # delete another partition
> 2  # delete the primary partition that contained the previous extended partition
> n  # create a new partition (i.e., recreate partition 2)
> e  # make it an extended partition
> n  # make another new partition, within the newly created partition
> 5  # make it #5
> n  # answer 'no'
> t  # change the type of the newest partition
> 5
> 8e # Linux LVM
> w  # write the changes to the partition table
```

### Refresh the partitions table in the kernel:

```sh
partprobe /dev/sda
```

## Resize the Physical Volume

```sh
pvresize /dev/sda5
```

## Extend the Logical Volume [^1]

```sh
lvextend -l +100%FREE /dev/{name of the volume group}/{name of logical volume}
```

## Finally, resize the ext4 file system:

```sh
resize2fs /dev/{volume group}/{logical volume}
```

---
[^1]: The names of the volume group and logical volumes can be seen in output from `lvs`.
