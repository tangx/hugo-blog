---
date: "2018-11-09T00:00:00Z"
description: k8s节点直接下载 gcr.io 原生镜像
keywords: k8s, sniproxy
tags:
- k8s
- docker
- proxy
title: K8S节点下载 gcr.io 原生镜像
---

# K8S下载 gcr.io 原生镜像

在国内是不能直接下载 `gcr.io` / `k8s.gcr.io` 等原生镜像的。

+ 使用比较权威的三方源 `aliyun` , `qcloud`
+ 将 `gcr.io` push 到 `hub.docker.com`
+ 自建镜像代理
+ 域名翻墙


## 域名翻墙

> 通过域名劫持，将目标地址直接解析到代理服务器上。

### sniproxy
所有你需要的，
+ 一个能直接访问 `gcr.ip` 的 `https(443)` 代理。 通过 [sniproxy](https://hub.docker.com/r/uyinn28/sniproxy/) 实现。
+ 通过 `防火墙` , `安全组` 限制访问来源。

```bash
# docker run -d --rm --network host --name sniproxy uyinn28/sniproxy
sudo docker run --rm -itd -p 443:443 --name sniproxy uyinn28/sniproxy
```

### 域名劫持

1. 通过自建 DNS 实现
  + [dnsmasq](https://wiki.archlinux.org/index.php/Dnsmasq_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))
  + [resolv.conf](http://man7.org/linux/man-pages/man5/resolv.conf.5.html)

```resolv.conf
options timeout:1 attempts:1
nameserver 1.2.3.4
nameserver 1.2.3.5
```

2. 通过绑定 `/etc/hosts` 实现

## k8s 使用 DaemonSet 修改

(可行)如果修改只想涉及到 `k8s` 集群的话， 可以使用 `DaemonSet` 将 `宿主机` 的 `/etc/` 目录挂到容器中进行修改。

