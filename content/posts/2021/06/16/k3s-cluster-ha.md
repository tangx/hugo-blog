---
date: "2021-06-16T00:00:00Z"
description: 5分钟k3s - k3s 使用外部数据库实现集群高可用
keywords: 5分钟k3s, k3s, k3s集群
tags:
- k3s
title: 5分钟k3s - k3s 使用外部数据库实现高可用
---

# 5分钟k3s - k3s 使用外部数据库实现高可用

| hostname | ipaddr|
| - | - |
| master01 | 192.168.0.12 |
| master01 | 192.168.0.45 |
| agent01 | 192.168.0.111 |

![k3s-cluster-ha](https://docs.rancher.cn/assets/images/k3s-architecture-ha-server-46bf4c38e210246bda5920127bbecd53.png)


## 1. 安装外置数据库

```bash
# 1. 安装一个外置数据库
# yum install mariadb mariadb-server

## ubuntu
apt update
apt install -y mysql-server
```

适配 `mysql8.0` 创建用户

```sql
-- mysql 8.0 创建解决办法:

-- 创建账户:create user '用户名'@'访问主机' identified by '密码';
-- 赋予权限:grant 权限列表 on 数据库 to '用户名'@'访问主机' ;(修改权限时在后面加with grant option)

create user k3s@'%' identified by 'mysql123';
grant all privileges on k3s.* to 'k3s'@'%' with grant option; 
flush privileges;


```

## 2. 创建集群

**Server 加入集群**

```bash
## 国外
curl -sfL https://get.k3s.io | sh -s - server \
  --datastore-endpoint="mysql://username:password@tcp(hostname:3306)/database-name"

## 国内
curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -s - server \
  --datastore-endpoint="mysql://username:password@tcp(hostname:3306)/database-name"

```

**Agent 加入集群**

```bash
K3S_TOKEN=SECRET k3s agent --server https://fixed-registration-address:6443
```

### 2.1 创建一个 Cluster

登陆到 master01, 初始化一个集群

```bash
curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -s - server --datastore-endpoint="mysql://k3s:mysql123@tcp(192.168.0.12:3306)/k3s"
```

### 2.2 新 Server 加入已有 Cluster

1. 登陆 `master01` , 同步集群信息到 `master02` 的相同目录下

```bash
# 1. 同步 server 配置
scp -r /var/lib/rancher/k3s/server/ master02:/var/lib/rancher/k3s/
```

2. 在 `master02` 安装 Server 加入已有集群

```bash

# 2. 在 master 02 执行安装命令。 这里与 master01 相同
curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -s - server --datastore-endpoint="mysql://k3s:mysql123@tcp(192.168.0.12:3306)/k3s"

```

## 3. agent 加入其他 server

在 master 上查看 `/var/lib/rancher/k3s/server/token` 获取 `K3S_TOKEN` 信息。

登陆 `agent` 安装 agent

```bash
K3S_TOKEN=K108e06ed4b156420240f7868e60ef::server:8a11cb61dbd7a2970a38e2e561cef08a

curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | K3S_TOKEN=${K3S_TOKEN} INSTALL_K3S_MIRROR=cn sh -s - agent --server https://192.168.0.12:6443
```

