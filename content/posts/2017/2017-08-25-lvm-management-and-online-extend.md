---
date: "2017-08-25T00:00:00Z"
description: LVM 管理
keywords: LVM, disk, fdisk
tags:
- system
- linux
title: LVM 磁盘管理与在线扩容
---

# LVM 磁盘管理与在线扩容

不上 LVM 的服务器都是耍流氓

## 在线扩容

通过 LVM 扩容的时候，
+ 被扩容的逻辑卷 `不需要重新格式化`
+ 被扩容的逻辑卷 `不需要被 umount`
+ 被扩容的逻辑卷上的业务 `不受影响`

> 在执行 `resize2fs 或 xfs_growfs` 的时候，会有一定等待时间，属于正常显现。

虽然扩容还是很安全的，不过，有条件的话，最好还是进行必要的备份


### 扩容步骤

1. 创建物理卷
  + `fdisk /dev/xvdk`
  + `pvcreate /dev/xvdk1`

2. 虚拟卷组扩容
  + `vgextend vg_groupname /dev/xvdg1`

3. 逻辑卷扩容
  + ext4 扩容
    + `lvextend -l +100%FREE /dev/vg_groupname/lv_name`

4. 执行扩容
    + ext4: `resize2fs /dev/vg_groupname/lv_name`
    + xfs : `xfs_growfs /dev/vg_groupname/lv_name`

### 扩容案例

```bash
[root@localhost ~]# vgextend vg_groupname /dev/xvdk1
  No physical volume label read from /dev/xvdk1
  Physical volume "/dev/xvdk1" successfully created
  Volume group "vg_groupname" successfully extended

[root@localhost ~]# lvextend  -l +100%FREE /dev/vg_groupname/lv_name
  Extending logical volume lv_name to 1.95 TiB
  Logical volume lv_name successfully resized

[root@localhost ~]# resize2fs  /dev/vg_groupname/lv_name
resize2fs 1.41.12 (17-May-2010)
Filesystem at /dev/vg_groupname/lv_name is mounted on /data; on-line resizing required
old desc_blocks = 94, new_desc_blocks = 125
Performing an on-line resize of /dev/vg_groupname/lv_name to 524279808 (4k) blocks.
The filesystem on /dev/vg_groupname/lv_name is now 524279808 blocks long.

[root@localhost ~]# df -h
Filesystem            Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup-lv_root
                       50G  7.1G   40G  16% /
tmpfs                 7.8G   12K  7.8G   1% /dev/shm
/dev/mapper/vg_groupname-lv_name
                      2.0T  754G  1.1T  41% /data
/dev/mapper/3ddbbackvg-3ddbbacklv
                      1.9T  1.3T  574G  69% /data1
/dev/xvda1            485M   32M  428M   7% /boot
```


## 创建 LVM 卷

### 格式化硬盘

在格式化硬盘后，需要将分区类型设置为 LVM 。
LVM 类型的编号为： `8e`

```bash
Command (m for help): t # 使用 t 修改分区类型
Selected partition 1    # 选择 分区
Hex code (type L to list codes): 8e # 8e表示为LVM # 设置分区
Changed system type of partition 1 to 8e (Linux LVM)
```

### 创建 LVM 卷
#### 创建物理卷

```bash
[root@localhost ~]# pvcreate /dev/sdb1
  Physical volume "/dev/sdb1" successfully created
```

#### 创建逻辑卷组

```bash
[root@localhost ~]# vgcreate vgdata /dev/sdb1
Volume group "vg_groupname" successfully created
```

#### 创建逻辑卷

逻辑卷被创建之后，和普通分区一样，需要格式化后才能被挂载

```bash
[root@localhost ~]# lvcreate -L 1G -n lv_data1 vgdata
Logical volume "lv_name" created.
[root@localhost ~]# mkfs.ext4 /dev/mapper/vg_groupname-lv_name
[root@localhost ~]# mount /dev/mapper/vg_groupname-lv_name /mnt
```


### 向逻辑卷组中加入物理卷

`vgextend vg_groupname /dev/sdb1 /dev/sdc1 /dev/sdd1`

```bash
[root@localhost ~]# vgextend VolGroup /dev/sdb2
  Volume group "VolGroup" successfully extended
You have new mail in /var/spool/mail/root
[root@localhost ~]# pvs
  PV     VG     Fmt  Attr PSize  PFree
  /dev/sda2  VolGroup lvm2 a--u 39.51g  0
  /dev/sdb1  vgdata   lvm2 a--u  5.36g 5.26g
  /dev/sdb2  VolGroup lvm2 a--u  4.63g 4.63g
```


### 从逻辑卷组中删除物理卷

`vgreduce vg_groupname /dev/sdb1 /dev/sdc1 /dev/sdd1`

```
[root@localhost ~]# vgreduce VolGroup /dev/sdb2
  Removed "/dev/sdb2" from volume group "VolGroup"
[root@localhost ~]# pvs
  PV     VG     Fmt  Attr PSize  PFree
  /dev/sda2  VolGroup lvm2 a--u 39.51g  0
  /dev/sdb1  vgdata   lvm2 a--u  5.36g 5.26g
  /dev/sdb2       lvm2 ----  4.63g 4.63g
```

### 调整逻辑卷大小

+ 容量增加至固定大小 1G : `lvextend -L 1G /dev/vg_groupname/lv_name`
+ 容量额外增加 300M : `lvextend -L +300M /dev/vg_groupname/lv_name`
+ 容量减小至固定大小 : `lvreduce -L 500M /dev/vg_groupname/lv_name`
+ 容量额外减少 200M : `lvreduce -L -200M /dev/vg_groupname/lv_name`

+ 按剩余百分增加 : `lvextend -l +100%FREE /dev/vg_groupname/lv_name`

```bash
[root@localhost ~]# lvextend -L 300M /dev/vgdata/lv_data1
  Size of logical volume vgdata/lv_data1 changed from 200.00 MiB (50 extents) to 300.00 MiB (75 extents).
  Logical volume lv_data1 successfully resized.
[root@localhost ~]# lvextend -L +300M /dev/vgdata/lv_data1
  Size of logical volume vgdata/lv_data1 changed from 300.00 MiB (75 extents) to 600.00 MiB (150 extents).
  Logical volume lv_data1 successfully resized.
[root@localhost ~]# resize2fs /dev/vgdata/lv_data1
resize2fs 1.41.12 (17-May-2010)
Resizing the filesystem on /dev/vgdata/lv_data1 to 614400 (1k) blocks.
The filesystem on /dev/vgdata/lv_data1 is now 614400 blocks long.

[root@localhost ~]# lvreduce -L 500M /dev/vgdata/lv_data1
  WARNING: Reducing active logical volume to 500.00 MiB.
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
Do you really want to reduce vgdata/lv_data1? [y/n]: y
  Size of logical volume vgdata/lv_data1 changed from 600.00 MiB (150 extents) to 500.00 MiB (125 extents).
  Logical volume lv_data1 successfully resized.
You have new mail in /var/spool/mail/root
[root@localhost ~]# lvreduce -L -50M /dev/vgdata/lv_data1
  Rounding size to boundary between physical extents: 48.00 MiB.
  WARNING: Reducing active logical volume to 452.00 MiB.
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
```

### 应用扩容方案

+ ext4: `resize2fs /dev/vg_groupname/lv_name`
+ xfs : `xfs_growfs /dev/vg_groupname/lv_name`



### 删除 LVM 卷

销毁一个 LVM 卷的时候，顺序与创建的时候相反

#### 删除逻辑卷

```bash
[root@localhost ~]# lvremove /dev/vg_groupname/lv_name        
Do you really want to remove active logical volume lv_data1? [y/n]: y
  Logical volume "lv_data1" successfully removed
```

#### 删除逻辑卷组

```bash
[root@localhost ~]# vgremove vg_groupname
  Volume group "vgdata" successfully removed
```

#### 删除物理卷

```bash
[root@localhost ~]# pvremove /dev/sdb1
  Labels on physical volume "/dev/sdb1" successfully wiped
```



### 显示 LVM 卷信息

#### 显示物理卷信息

+ `pvdisplay`
+ `pvdisplay /dev/sdb1`

```
[root@s001-bastion ~]# pvdisplay /dev/sdc1
  --- Physical volume ---
  PV Name               /dev/sdc1
  VG Name               vgtest
  PV Size               2.00 GiB / not usable 3.32 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              511
  Free PE               0
  Allocated PE          511
  PV UUID               AkXkkl-aYCb-Incz-lAVg-PP4Y-Yycw-r1a5an
```

#### 显示逻辑卷组信息

+ `vgdisplay`
+ `vgdisplay vg_groupname`

```
[root@s001-bastion ~]# vgdisplay  vg_groupname
  --- Volume group ---
  VG Name               vg_groupname
  System ID             
  Format                lvm2
  Metadata Areas        4
  Metadata Sequence No  9
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                4
  Act PV                4
  VG Size               3.99 GiB
  PE Size               4.00 MiB
  Total PE              1021
  Alloc PE / Size       1021 / 3.99 GiB
  Free  PE / Size       0 / 0   
  VG UUID               FxKZRi-mkjD-OVJf-dh1k-VN0w-GjzA-4DVxf7
```

#### 显示逻辑卷组信息

+ `lvdisplay`
+ `lvdisplay /dev/vg_groupname/lv_name`

```
[root@s001-bastion ~]# lvdisplay /dev/vg_groupname/lv_name
  --- Logical volume ---
  LV Path                /dev/vg_groupname/lv_name
  LV Name                lv_name
  VG Name                vg_groupname
  LV UUID                k2I7oG-y3q9-1Dmc-MZ5v-D2it-NBeK-jVpOE7
  LV Write Access        read/write
  LV Creation host, time s001-bastion, 2017-08-16 16:57:29 +0800
  LV Status              available
  # open                 1
  LV Size                3.99 GiB
  Current LE             1021
  Segments               4
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2
```

## 记一次 lvm 在线扩容

之前案例不同， 这次实在 Aliyun 上直接 **扩容原磁盘大小** ， 而非新加磁盘。 

因此，核心点在于如何对 `物理卷` 扩容。

> 需要注意的是： 物理卷扩容并[不需要和普通分区一样，先删除再重建](https://help.aliyun.com/document_detail/25452.html?spm=5176.2020520101.0.0.457c4df5f8vH9j)。 直接 `pvresize` 即可。

### 命令总结

```bash
# pvresize /dev/vdb
# lvextend -l +100%FREE /dev/mapper/docker-bootstrap
# resize2fs /dev/mapper/docker-bootstrap
```

### 命令记录

```bash

[root@iZ2ze0ky5ovykfx08vvmsxZ ~]# df -h |grep boot
/dev/mapper/docker-bootstrap   40G  2.2G   36G   6% /var/lib/docker


[root@iZ2ze0ky5ovykfx08vvmsxZ ~]# pvresize --help
  pvresize: Resize physical volume(s)

pvresize
	[--commandprofile ProfileName]
	[-d|--debug]
	[-h|-?|--help]
	[--reportformat {basic|json}]
	[--setphysicalvolumesize PhysicalVolumeSize[bBsSkKmMgGtTpPeE]
	[-t|--test]
	[-v|--verbose]
	[--version]
	PhysicalVolume [PhysicalVolume...]

[root@iZ2ze0ky5ovykfx08vvmsxZ ~]# pvchange --help^C
[root@iZ2ze0ky5ovykfx08vvmsxZ ~]# pvresize /dev/vdb
  Physical volume "/dev/vdb" changed
  1 physical volume(s) resized / 0 physical volume(s) not resized
[root@iZ2ze0ky5ovykfx08vvmsxZ ~]# pvdisplay
  --- Physical volume ---
  PV Name               /dev/vdb
  VG Name               docker
  PV Size               300.00 GiB / not usable 3.00 MiB
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              76799
  Free PE               51204
  Allocated PE          25595
  PV UUID               Cqxbco-9dJ7-uOot-SxRm-gUft-aVM8-Dj2ilE

[root@iZ2ze0ky5ovykfx08vvmsxZ ~]# lvextend -l ^C
[root@iZ2ze0ky5ovykfx08vvmsxZ ~]# # lvextend -l +100%FREE /dev/mapper/docker-bootstrap
[root@iZ2ze0ky5ovykfx08vvmsxZ ~]#

[root@iZ2ze0ky5ovykfx08vvmsxZ ~]# # lvextend -l +100%FREE /dev/mapper/docker-bootstrap
[root@iZ2ze0ky5ovykfx08vvmsxZ ~]# lvextend -l +100%FREE /dev/mapper/docker-bootstrap
  Size of logical volume docker/bootstrap changed from 40.00 GiB (10239 extents) to 240.01 GiB (61443 extents).
  Logical volume docker/bootstrap successfully resized.
[root@iZ2ze0ky5ovykfx08vvmsxZ ~]# resize2fs /dev/mapper/docker-bootstrap
resize2fs 1.42.9 (28-Dec-2013)
Filesystem at /dev/mapper/docker-bootstrap is mounted on /var/lib/docker; on-line resizing required
old_desc_blocks = 5, new_desc_blocks = 31
The filesystem on /dev/mapper/docker-bootstrap is now 62917632 blocks long.


[root@iZ2ze0ky5ovykfx08vvmsxZ ~]# df -h |grep /dev/mapper/docker-bootstrap
/dev/mapper/docker-bootstrap  237G  2.2G  224G   1% /var/lib/docker
```
