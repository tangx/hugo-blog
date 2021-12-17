---
date: "2019-11-26T00:00:00Z"
description: calico 是一种基础 vRouter 的3层网络模型 (BGP 网络)。 在应用到 k8s 中，可以提到常见的 flannel， 提高网络性能。
keywords: k8s, network
tags:
- k8s
- network
- calico
title: calico 网络模型的简单笔记
---

# calico 简单笔记

calico 是一种基础 vRouter 的3层网络模型 (BGP 网络)。 在应用到 k8s 中，可以提到常见的 flannel。
使用节点主机作为 vRouter 实现 3层转发。 提高网络性能。

![2019-11-26/2019-11-26-calico-simple-note/20191126222412.png](https://m.tangx.in/images/2019-11-26/2019-11-26-calico-simple-note/20191126222412.png)

## calico 的网络模型

calico 可以通过设置 IP-in-IP 控制网络模型:

> https://docs.projectcalico.org/v3.5/usage/configuration/ip-in-ip


1. `ipipMode=Never`: BGP 模型。 完全不使用 IP-in-IP 隧道， 这就是常用的 BGP 模型。
![2019-11-26/2019-11-26-calico-simple-note/20191126222504.png](https://m.tangx.in/images/2019-11-26/2019-11-26-calico-simple-note/20191126222504.png)

1. `ipipMode=Always`: calico 节点直接通过 IP 隧道的的方式实现节点互通。 这实际上是一种 overlay 网络模型， 可以认为这是一种使用与跨3层通信的妥协。
![2019-11-26/2019-11-26-calico-simple-note/![](这里有图.png)](https://m.tangx.in/images/2019-11-26/2019-11-26-calico-simple-note/![](这里有图.png))


1. `ipipMode=CrossSubnet`: BGP 和 Overlay 的混合模型。通过策略控制在指定的子网内使用 BGP 模型。出子网则使用 overlay。 *注意，具体设置还没看，可能是指定的使用 overlay，其他使用 bgp*

## calico 的缺陷

> https://www.cnblogs.com/kevingrace/p/6864804.html

由于calico的通信机制是完全基于三层的，这种机制也带来了一些缺陷，例如：

1. calico目前只支持TCP、UDP、ICMP、ICMPv6协议，如果使用其他四层协议（例如NetBIOS协议），建议使用weave、原生overlay等其他overlay网络实现。
1. 基于三层实现通信，在二层上没有任何加密包装，因此只能在私有的可靠网络上使用。
1. 流量隔离基于iptables实现，并且从etcd中获取需要生成的隔离规则，有一些性能上的隐患。（待商榷）

## calico 与 flannel 等对比

### 性能对比

> https://blog.csdn.net/ganpuzhong42/article/details/77853131
整个过程中始终都是根据iptables规则进行路由转发，并没有进行封包，解包的过程，这和flannel比起来效率就会快多了。


** calico 原理** 
![2019-11-26/2019-11-26-calico-simple-note/20191126224011.png](https://m.tangx.in/images/2019-11-26/2019-11-26-calico-simple-note/20191126224011.png)

** flannel 原理**
![2019-11-26/2019-11-26-calico-simple-note/20191126224043.png](https://m.tangx.in/images/2019-11-26/2019-11-26-calico-simple-note/20191126224043.png)

由于 calico BGP 模式走的是 3层转发，没有 overlay 网络实现时的封包解包操作。
因此
1. 资源消耗上更少（不封包解包，cpu消耗更少）
1. 转发效率上更优，带宽消耗更少（包更小）

![2019-11-26/2019-11-26-calico-simple-note/20191126223132.png](https://m.tangx.in/images/2019-11-26/2019-11-26-calico-simple-note/20191126223132.png)


## calico BGP 路由学习

+ 在节点较少的情况下， calico 可以使用 `mesh` 使节点之间两点相连宣告 BGP。 随着节点增多， 连接会呈指数级的增加。
+ 当节点较多（30以上），可以使用 BGP 路由反射（BGP Route Reflectors）方式宣告 BGP。 反射模式配置 [calico-bgp-rr.md](calico-bgp-rr.md)

## calico 组件清单

> https://www.kubernetes.org.cn/4960.html

+ etcd: 保存路由信息
+ Fliex: 管理接口，编写路由，配置 ACLs，报告状态。
+ BGP Client:
+ BGP Router Reflectors: 
+ Orchestrator. Plguin: 管理 API
+ 

## calico 支持的公有云

+ 青云: 仅限 `同一个私有网络(vxnet)下的主机`。
+ AWS: 同子网

