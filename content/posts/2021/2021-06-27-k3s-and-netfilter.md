---
date: "2021-06-27T00:00:00Z"
description: 为什么我启动了 nginx 监听 80 端口却不生效。 为什么服务器没有监听 80 端口却被k3s占用了
keywords: iptables, netfilter, k3s
tags:
- k3s
- iptables
title: netfilter-五链四表 - 为什么服务器没有监听 80 端口却被k3s占用了
---

# netfilter 五链四表 - 为什么服务器没有监听 80 端口却被k3s占用了

其实标题已经给出答案了。 希望大家都能夯实基础， 万事逃不过一个 **道理和规则** 。

## 现象

一天，发现服务器上 80 端口不能正常访问了， 无论怎么都是 `404 page not found` 。 这就奇怪了。

ssh 登录终端， 查看端口监听情况, nginx 服务器启动的好端端的在那里？

```bash
netstat -tunpl |grep 80

tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      1103/nginx: master
tcp        0      0 0.0.0.0:31807           0.0.0.0:*               LISTEN      314008/k3s server
tcp6       0      0 :::80                   :::*                    LISTEN      1103/nginx: master
```

![netstat-tunpl.png](/assets/img/post/2021/06/k3s-and-netfilter/netstat-tunpl.png)

这就奇怪了啊？ 即使使用 `curl 127.0.0.1` 走本地结果也是  `404 page not found` 。

即使关闭 nginx， 依然可以 tenlet， 并得到一个 http 服务

![stop-nginx-and-telnet-80.png](/assets/img/post/2021/06/k3s-and-netfilter/stop-nginx-and-tenlnet-80.png)

一时间无数神兽在脑中奔腾而过。 怎么路由就过去不去呢？ 中 **内存马** 了？

冷静下来， 重新整理一下现象。

1. 80 端口没有被占用， 但是依然运行这一个 http 服务器。
2. 依然可以启动一个使用 80 端口的服务， 但是不能启动第二个。
3. 无论如何， http 请求是不会达到 **2.** 中启动的服务的。

## 排错

一步一步来

### 停服排查

在搜索了无数类似 **怎么不监听端口但能接受流量**, **内存马**, **使用 dev 设备开启服务方式** 等问题无果之后

冷静下来， 决定一个一个停服。 

1. 关闭 `docker` ，问题存在
2. 关闭 `k3s`， 问题消失。

那么问题一定在 `k3s` 上， 至少不是被黑了。

### 分析 k3s 

![kgs.png](/assets/img/post/2021/06/k3s-and-netfilter/kgs.png)

使用命令 `kubectl get service -n kube-system` 看到 k3s 默认安装中确实又一个和平常使用的方式不一样 `traefik LoadBalancer ...` 或许这个有关

查找了 k3s 和 traefik 的官方文档， 没有找到和这里相关的信息。

仔细思考， `k8s` 中网络转发方案大概以下几种 `iptables, ipvs, eBPF`。 

1. 其中 `eBPF` 需要开启内核 xxx 功能支持， 而且也不是主流， k3s 默认情况下应该是不会开的。
2. `iptables, ipvs` 都是需要修改 `iptables(netfilter)` 规则

> 这里补充以下， 虽然常说 `iptables 防火墙` , 但 `iptables` 应该算 `netfilter` 的一个命令行客户端。 实际使用 `iptables` 操作的还是内核中 `netfilter 链/表` 规则。

使用 `iptables -L -n -t nat` 查看， 果然找到了 80 端口相关的信息。

![iptables-nL-nat.png](/assets/img/post/2021/06/k3s-and-netfilter/iptable-nL-nat.png) 

继续跟中，找到了 `dameonset/svclb-traefik` 下的 pod。

![kgp.png](/assets/img/post/2021/06/k3s-and-netfilter/kgp-wide.png)

### 破题

重新把思路聚集回来， 思考

1. **怎样在 linux 中劫持流量** 
2. **服务监听端口怎么就访问不通**

还真被我想到了 `PREROUTING` 和 `POSTROUTING`。 翻阅几年前的笔记 [iptables 基础知识和基本用法](https://tangx.in/2017/08/31/iptables-basic-theory-and-useage/)， 还是不得其解。

> 事后回顾: [iptables 基础知识和基本用法](https://tangx.in/2017/08/31/iptables-basic-theory-and-useage/) 在本问题中是有一定缺陷的。
>
> 1. 该文章主要说明 iptable 的用法， 主要立足于 iptable **应用** 本身。
> 2. 该文章视野过小， **不仅没有** 提及到 netfilter ， **更没有** 阐述到 **流量转发(内核态)** 与 **端口监听(用户态)** 之间的关系。


重新搜索相关 `iptables` 的相关文档， 找到了一篇还不错的 [iptables详解（1）：iptables概念](https://www.zsythink.net/archives/1199) 。 仔细阅读， 看到 **PrrRouting(内核态) 与 application(用户态)** 之间的关系之后瞬间茅塞顿开。

![netfilter-kernel-and-user-space.png](/assets/img/post/2021/06/k3s-and-netfilter/netfilter-kernel-user-space.png)


那么原因就很明显了

1. 访问 80 端口的流量请求到 服务器上。
2. 进入 `PreRouting` 链， 将流量转发到 `k3s 的 svclb-traefik` 服务上。
3. `svclb-traefik` 服务在根据 `ingress` 将流量转发到对应的后端服务。
4. 后端服务响应请求，并作出反应。
5. 因为 `3.` 中没有命中 `ingress` 规则而无转发， 因此 `traefik` 就走默认行为， 影响 `404 not found` 。


## 补充

`netfilter` 不能能对 `IP` 劫持流量， 也能在其他地方行使规则。 参考 [netfilter hooks](https://wiki.nftables.org/wiki-nftables/index.php/Netfilter_hooks)

![nf-hooks.png](/assets/img/post/2021/06/k3s-and-netfilter/nf-hooks.png)
