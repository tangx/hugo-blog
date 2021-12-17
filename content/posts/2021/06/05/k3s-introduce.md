---
date: "2021-06-05T00:00:00Z"
description: K3s 是一个轻量级的 Kubernetes 发行版，它针对边缘计算、物联网等场景进行了高度优化
keywords: k3s, k8s, cloudnative
tags:
- k3s
- k8s
- cloudnative
title: 5分钟k3s-什么是 K3s? K3s 简介与适用场景介绍
---

# 什么是 K3s?

![k3s-roadmap-intro](/assets/img/post/2021/06/k3s/k3s-roadmap-intro.png)

K3s 是一个轻量级的 Kubernetes 发行版，它针对边缘计算、物联网等场景进行了高度优化。

![k3s.png](https://static001.infoq.cn/resource/image/ef/3c/ef6d2585035a62e5b8351fff9920f63c.png)

K3s 有以下增强功能：

+ 打包为单个二进制文件。
+ 使用基于 sqlite3 的轻量级存储后端作为默认存储机制。同时支持使用 etcd3、MySQL 和 + PostgreSQL 作为存储机制。
+ 封装在简单的启动程序中，通过该启动程序处理很多复杂的 TLS 和选项。
+ 默认情况下是安全的，对轻量级环境有合理的默认值。
+ 添加了简单但功能强大的batteries-included功能，例如：本地存储提供程序，服务负载均衡器，Helm + controller 和 Traefik Ingress controller。
+ 所有 Kubernetes control-plane 组件的操作都封装在单个二进制文件和进程中，使 K3s 具有自动化和+ 管理包括证书分发在内的复杂集群操作的能力。
+ 最大程度减轻了外部依赖性，K3s 仅需要 kernel 和 cgroup 挂载。 K3s 软件包需要的依赖项包括：
  + containerd
  + Flannel
  + CoreDNS
  + CNI
  + 主机实用程序（iptables、socat 等）
  + Ingress controller（Traefik）
  + 嵌入式服务负载均衡器（service load balancer）
  + 嵌入式网络策略控制器（network policy controller）


# 适用场景

K3s 适用于以下场景：

+ 边缘计算-Edge
+ 物联网-IoT
+ CI
+ Development
+ ARM
+ 嵌入 K8s

由于运行 K3s 所需的资源相对较少，所以 K3s 也适用于**开发**和**测试** 等试验性场景。
