---
date: "2018-11-15T00:00:00Z"
description: some word here
keywords: k8s, heketi, glusterfs
tags:
- k8s
- glusterfs
- storage
title: K8S 中使用 Heketi 管理 GlusterFS
---

# K8S 中使用 Heketi 管理 GlusterFS

与 [官方文档不同](https://github.com/gluster/gluster-kubernetes) ， 本文中的 `glusterfs` 是独立与 `k8s` 之外的。


## Heketi

[`heketi` 项目](https://github.com/heketi/heketi) 为 GlusterFS 提供 RESTful 的 API 管理。

### Requirements

+ System must have glusterd service enabled and glusterfs-server installed
+ Disks registered with Heketi must be in raw format.

目前提供两种管理方式: `ssh`, `kubernetes`

### heketi-ssh

**SSH Access**

+ SSH user and `public key` already setup on the node
+ SSH user must have `password-less sudo`
+ Must be able to `run sudo commands from ssh`. This requires `disabling requiretty` in the `/etc/sudoers` file

#### 使用容器部署

+ https://hub.docker.com/r/heketi/heketi/ 

### heketi-kubernetes

+ 带实现

#### 勘误

在使用 K8S 部署时， 如果客户端报错说找不到目标机的 `glusterd` ， 可能是因为 `Heketi Pod` 权限不够，不能获取到 `相应 namespace` 中的信息。

## GlusterFS

### 程序

机器上装好 `glusterfs` 即可， 不用对节点之间进行 `gluster peer probe <node>` 

+ [CentOS7 安装 GlusterFS(Eng)](https://wiki.centos.org/SpecialInterestGroup/Storage/gluster-Quickstart) 
+ [CentOS7 安装 GlusterFS(Chn)](https://wiki.centos.org/zh/HowTos/GlusterFSonCentOS)

### 磁盘

通过 `heketi` 管理后， `glusterfs` 集群[磁盘必须是 `RAW` 格式](https://github.com/gluster/gluster-kubernetes/issues/393)， 什么都没有。

+ 没有分区 (No partitions)
+ 没有任何文件系统 (no filesystem)
+ 没有 LVM (no LVM artifacts)

如果之前已经格式化过了磁盘，使用 `wipefs -a /dev/vdb` 清空磁盘分区。 


## 参考资料
+ https://jimmysong.io/kubernetes-handbook/practice/using-heketi-gluster-for-persistent-storage.html
+ 上述各链接