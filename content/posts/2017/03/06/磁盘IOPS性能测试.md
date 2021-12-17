---
date: "2017-03-06T00:00:00Z"
description: 使用 FIO 测试磁盘 IOPS 性能
keywords: system
tags:
- system
title: 使用 FIO 测试磁盘 IOPS 性能
---


# 使用 FIO 测试磁盘 IOPS 性能

[磁盘IOPS测试](http://www.centoscn.com/CentOS/Intermediate/2016/0206/6736.html)

## linux 使用 FIO 测试

FIO是测试IOPS的非常好的工具，用来对硬件进行压力测试和验证，支持13种不同的I/O引擎，包括:sync,mmap, libaio, posixaio, SG v3, splice, null, network, syslet, guasi, solarisaio 等等。 

### FIO 安装
 
```bash
# centos6 可以通过 yum 安装
sudo yum -y install fio

# 编译安装
wget http://brick.kernel.dk/snaps/fio-2.0.7.tar.gz 
yum install libaio-devel 
tar -zxvf fio-2.0.7.tar.gz 
cd fio-2.0.7 
make 
make install
```

### 磁盘读写测试


```bash
# 这段测试的含义是测试随机写，每次写入大小16K，文件大小为10G，ioengine=libaio，运行1000秒(runtime)，跳过buffer，其中 -name 指向到你想测试的磁盘上的文件。
fio -direct=1  -iodepth=64  -rw=randwrite  -ioengine=libaio  -bs=16k  -size=10G  -numjobs=1  -runtime=1000  -group_reporting  -name=/storage/iotest

# 减少 runtime 和 生成 size
fio -direct=1  -iodepth=64  -rw=randwrite  -ioengine=libaio  -bs=16k  -size=256M  -numjobs=1  -runtime=100  -group_reporting  -name=/storage/iotest

```

```bash
# 随机读
fio -filename=/dev/sdb1 -direct=1 -iodepth 1 -thread -rw=randread -ioengine=psync -bs=16k -size=200G -numjobs=10 -runtime=1000 -group_reporting -name=mytest 

# 顺序读： 
fio -filename=/dev/sdb1 -direct=1 -iodepth 1 -thread -rw=read -ioengine=psync -bs=16k -size=200G -numjobs=30 -runtime=1000 -group_reporting -name=mytest 

# 随机写： 
fio -filename=/dev/sdb1 -direct=1 -iodepth 1 -thread -rw=randwrite -ioengine=psync -bs=16k -size=200G -numjobs=30 -runtime=1000 -group_reporting -name=mytest 

# 顺序写： 
fio -filename=/dev/sdb1 -direct=1 -iodepth 1 -thread -rw=write -ioengine=psync -bs=16k -size=200G -numjobs=30 -runtime=1000 -group_reporting -name=mytest 

# 混合随机读写： 
fio -filename=/dev/sdb1 -direct=1 -iodepth 1 -thread -rw=randrw -rwmixread=70 -ioengine=psync -bs=16k -size=200G -numjobs=30 -runtime=100 -group_reporting -name=mytest -ioscheduler=noop

```

+ filename=/dev/sdb1 测试文件名称，通常选择需要测试的盘的data目录。 
+ direct=1 测试过程绕过机器自带的buffer。使测试结果更真实。 
+ rw=randwrite 测试随机写的I/O 
+ rw=randrw 测试随机写和读的I/O 
+ bs=16k 单次io的块文件大小为16k 
+ bsrange=512-2048 同上，提定数据块的大小范围 
+ size=5g 本次的测试文件大小为5g，以每次4k的io进行测试。 
+ numjobs=30 本次的测试线程为30. 
+ runtime=1000 测试时间为1000秒，如果不写则一直将5g文件分4k每次写完为止。 
+ ioengine=psync io引擎使用pync方式 
+ rwmixwrite=30 在混合读写的模式下，写占30% 
+ group_reporting 关于显示结果的，汇总每个进程的信息。 

+ lockmem=1g 只使用1g内存进行测试。 
+ zero_buffers 用0初始化系统buffer。 
+ nrfiles=8 每个进程生成文件的数量。

### dd命令测试硬盘的读写速度

```bash
# 写速度
time dd if=/dev/zero of=/var/test bs=8k count=1000000

# 读速度
time dd if=/var/test of=/dev/null bs=8k count=1000000
```

## windows 使用 AnvilPro 工具

