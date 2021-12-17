---
date: "2021-06-07T00:00:00Z"
description: k3s单节点架构介绍与安装卸载管理
keywords: k3s架构, k3s安装, k3s卸载
tags:
- k3s
title: 5分钟k3s - k3s单节点架构介绍与安装卸载管理
---

# 5分钟k3s - k3s单节点架构介绍与安装卸载管理

## k3s 单 Server 节点架构

K3s 单节点集群的架构如下图所示，该集群有一个内嵌 SQLite 数据库的单节点 K3s server。

在这种配置中，每个 agent 节点都注册到同一个 server 节点。K3s 用户可以通过调用 server 节点上的 K3s API 来操作 Kubernetes 资源。

单节点k3s server的架构

![k3s-single-server](https://docs.rancher.cn/assets/images/k3s-architecture-single-server-42bb3c4899985b4f6d8fd0e2130e3c0e.png)

## Server 安装

## 安装条件

**两个节点不能有相同的主机名**

+ 如果您的所有节点都有相同的主机名，请使用 `--with-node-id` 选项为每个节点添加一个随机后缀，+ 或者为您添加到集群的每个节点设计一个独特的名称，用 `--node-name` 或 `$K3S_NODE_NAME` 传递。


## 安装

### 安装 Server

```bash
# 通用
curl -sfL https://get.k3s.io | sh -


# 国内安装
curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -

```

执行命令， 不到一分钟集群就安装好了

+ K3s 服务将被配置为在节点重启后或进程崩溃或被杀死时自动重启。
+ 将安装其他实用程序，包括kubectl、crictl、ctr、k3s-killall.sh 和 k3s-uninstall.sh。
+ 将kubeconfig文件写入到/etc/rancher/k3s/k3s.yaml，由 K3s 安装的 kubectl 将自动使用该文件。

```log
curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -

[INFO]  Finding release for channel stable
[INFO]  Using v1.21.1+k3s1 as release
[INFO]  Downloading hash http://rancher-mirror.cnrancher.com/k3s/v1.21.1-k3s1/sha256sum-amd64.txt
[INFO]  Downloading binary http://rancher-mirror.cnrancher.com/k3s/v1.21.1-k3s1/k3s
[INFO]  Verifying binary download
[INFO]  Installing k3s to /usr/local/bin/k3s
[INFO]  Creating /usr/local/bin/kubectl symlink to k3s
[INFO]  Creating /usr/local/bin/crictl symlink to k3s
[INFO]  Skipping /usr/local/bin/ctr symlink to k3s, command exists in PATH at /usr/bin/ctr
[INFO]  Creating killall script /usr/local/bin/k3s-killall.sh
[INFO]  Creating uninstall script /usr/local/bin/k3s-uninstall.sh
[INFO]  env: Creating environment file /etc/systemd/system/k3s.service.env
[INFO]  systemd: Creating service file /etc/systemd/system/k3s.service
[INFO]  systemd: Enabling k3s unit
[INFO]  systemd: Starting k3s
```

### 安装 Client

安装方法与 Server 类似。

不过需要额外指定 `K3S_URL` 和 `K3S_TOKEN` 环境变量运行安装脚本， 以指定添加到的目标 Server 集群。

+ 设置 `K3S_URL` 参数会使 K3s 以 worker 模式运行。K3s agent 将在所提供的 URL 上向监听的 K3s 服务器注册。
+ `K3S_TOKEN` 使用的值存储在你的服务器节点上的 `/var/lib/rancher/k3s/server/node-token` 路径下。





```bash 
## 通用命令
curl -sfL https://get.k3s.io | K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken sh -

## 国内用户
curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken sh -

```

### 使用 kubectl 管理集群

可以看到 `kubectl` 命令是 `k3s` 命令的一个子命令。

```bash
# ls -al /usr/local/bin/kubectl
lrwxrwxrwx 1 root root 3 Feb  2 17:12 /usr/local/bin/kubectl -> k3s
```

现在可以任意使用熟悉的 `kubectl` 进行集群管理了。

```bash
# kubectl get node
NAME               STATUS     ROLES                  AGE    VERSION
test       Ready      control-plane,master   124d   v1.20.7+k3s1
test-0001   NotReady   <none>                 3s     v1.21.1+k3s1

kubectl get pod --all-namespaces
```

## 卸载

k3s 的所有命令脚本，默认都在 `/usr/local/bin` 下， 以 `k3s-*` 开头。 

```bash
# server
/usr/local/bin/k3s-uninstall.sh

# agent
/usr/local/bin/k3s-agent-uninstall.sh
```
