---
date: "2017-01-23T00:00:00Z"
description: AWS EFS 使用笔记
keywords: aws, nfs
tags:
- aws
title: AWS EFS 使用笔记
---

# AWS EFS 使用笔记


```bash
# 安装 nfs utils 组件
# On an Amazon Linux, Red Hat Enterprise Linux, or SuSE Linux instance:
sudo yum install -y nfs-utils
# On an Ubuntu instance:
#sudo apt-get install nfs-common
```

## iptables 与 sg 设置

mount 的时候注意防火墙 或 security group 的设置
EFS 使用了防火墙，需要将 EFS 所在的 SG 允许中设置允许访问来源。

+ portmap 端口 111 udp/tcp；
+ nfsd 端口 2049 udp/tcp；
+ mountd 端口 "xxx" udp/tcp

> 通常设置允许某 security group.


## 挂载
### 使用域名挂载

```bash
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $EFS_DOMAIN:/ $MOUNT_POINT
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 fs-55xxxxfc.efs.us-west-2.amazonaws.com:/ /usr/share/nginx/html
```

### 使用 IP 地址挂载

```bash
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $EFS_IPADDR_IN_AZ:/ $MOUNT_POINT
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 172.xx.xxx.251:/ efs
```

## EC2 [自动挂载](https://docs.aws.amazon.com/zh_cn/efs/latest/ug/mount-fs-auto-mount-onreboot.html) EFS

### 写入 fstab

已创建的 EC2 可以在 fstab 中写入挂载信息

```bash
#vi /etc/fstab

mount-target-DNS:/ efs-mount-point nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0

```

### 创建 EC2 时挂载

通过 [cloud-init](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AmazonLinuxAMIBasics.html#CloudInit)，可以在创建 EC2 的时候指定挂载信息

在创建引到界面第三步：**Step 3: Configure Instance Details** 中的 **Advanced** 选项中。复制粘贴以下字段。

```yaml

#cloud-config
package_upgrade: true
packages:
- nfs-utils
runcmd:
- mkdir -p /var/www/html/efs-mount-point/
- chown ec2-user:ec2-user /var/www/html/efs-mount-point/
- echo "file-system-id.efs.aws-region.amazonaws.com:/ /var/www/html/efs-mount-point nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab
- mount -a -t nfs4

```

> 注意： 将 file-system-id, aws-region, and efs-mount-point 替换为实际信息。



## 遗留问题
+ mount efs 后， nginx 提示 403 Forbidden
