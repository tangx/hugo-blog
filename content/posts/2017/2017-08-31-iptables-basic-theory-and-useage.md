---
date: "2017-08-31T00:00:00Z"
description: iptables 基础管理
keywords: iptables
tags:
- system
title: iptables 基础知识和基本用法
---


# iptables 基础知识和基本用法


## iptables传输数据包的过程

1. 当一个数据包进入网卡时，它首先进入PREROUTING链，内核根据数据包目的IP判断是否需要转送出去。
2. 如果数据包就是进入本机的，它就会沿着图向下移动，到达INPUT链。数据包到了INPUT链后，任何进程都会收到它。本机上运行的程序可以发送数据包，这些数据包会经过OUTPUT链，然后到达POSTROUTING链输出。
3. 如果数据包是要转发出去的，且内核允许转发，数据包就会如图所示向右移动，经过FORWARD链，然后到达POSTROUTING链输出。


![2017-08-31-iptables-basic-theory.png](/assets/img/post/2017/2017-08-31-iptables-basic-theory.png)

### 规则表
1. filter表——三个链：INPUT、FORWARD、OUTPUT
作用：过滤数据包  内核模块：iptables_filter.
2. Nat表——三个链：PREROUTING、POSTROUTING、OUTPUT
作用：用于网络地址转换（IP、端口） 内核模块：iptable_nat
3. Mangle表——五个链：PREROUTING、POSTROUTING、INPUT、OUTPUT、FORWARD
作用：修改数据包的服务类型、TTL、并且可以配置路由实现QOS内核模块：iptable_mangle(别看这个表这么麻烦，咱们设置策略时几乎都不会用到它)
4. Raw表——两个链：OUTPUT、PREROUTING
作用：决定数据包是否被状态跟踪机制处理  内核模块：iptable_raw
(这个是REHL4没有的，不过不用怕，用的不多)

### 规则链

1. INPUT——进来的数据包应用此规则链中的策略
2. OUTPUT——外出的数据包应用此规则链中的策略
3. FORWARD——转发数据包时应用此规则链中的策略
4. PREROUTING——对数据包作路由选择前应用此链中的规则
（记住！所有的数据包进来的时侯都先由这个链处理）
5. POSTROUTING——对数据包作路由选择后应用此链中的规则
（所有的数据包出来的时侯都先由这个链处理）


### 规则表之间的优先顺序

`Raw——mangle——nat——filter`

规则链之间的优先顺序（分三种情况）：

**第一种情况：入站数据流向**

从外界到达防火墙的数据包，先被PREROUTING规则链处理（是否修改数据包地址等），之后会进行路由选择（判断该数据包应该发往何处），如果数据包的目标主机是防火墙本机（比如说Internet用户访问防火墙主机中的web服务器的数据包），那么内核将其传给INPUT链进行处理（决定是否允许通过等），通过以后再交给系统上层的应用程序（比如Apache服务器）进行响应。

**第二冲情况：转发数据流向**

来自外界的数据包到达防火墙后，首先被PREROUTING规则链处理，之后会进行路由选择，如果数据包的目标地址是其它外部地址（比如局域网用户通过网关访问QQ站点的数据包），则内核将其传递给FORWARD链进行处理（是否转发或拦截），然后再交给POSTROUTING规则链（是否修改数据包的地址等）进行处理。

**第三种情况：出站数据流向**
防火墙本机向外部地址发送的数据包（比如在防火墙主机中测试公网DNS服务器时），首先被OUTPUT规则链处理，之后进行路由选择，然后传递给POSTROUTING规则链（是否修改数据包的地址等）进行处理。


![2017-08-31-iptables-basic-theory.png](/assets/img/post/2017/2017-08-31-iptables-basic-theory-tables.png)


## iptables filter 规则命令

`iptables -t 表名 -A/-I 链名 -p 协议 --dport/--sport 端口 -s/-d IP/MASK  -i|-o 网卡 -j ACTION`
`iptables -t TABLE -A|-I CHAIN -p PROTOCOL --dport|--sport PORT -s|-d IP/MASK -i|-o ETH -j ACTION`

![2017-08-31-iptables-basic-theory.png](/assets/img/post/2017/2017-08-31-iptables-basic-command.jpg)
![2017-08-31-iptables-basic-theory.png](/assets/img/post/2017/2017-08-31-iptables-basic-paraments.jpg)


```bash

# 添加 允许来自 192.168.1.0/24 访问 tcp 80 端口的包
iptables -A INPUT -p tcp --dport 80 -s 192.168.1.0/24 -j ACCEPT

# 插入 拒绝所有访问 udp 22 端口的包
iptables -I INPUT -p udp --dport 22 -j DROP

# 添加 允许所有来自 192.168.1.1 的包
iptables -A INPUT -s 192.168.1.1/32 -j ACCEPT

# 添加出链 允许 来自 8080 端口 到 10.10.0.0/16 网段的 tcp 协议的包
iptables -A OUTPUT -p tcp --sport 8080 -d 10.10.0.0/16 -j ACCEPT

# 插入出链 拒绝 目标端口为 19999 ，来自网络 10.24.1.0/24 的 udp 协议的包
iptables -I OUTPUT -p udp --dport 19999 -s 10.24.1.0/24 -j DROP

# 允许 来自 192.168.1.0/24 网段到 18080 ~ 18090 端口的 tcp 包
iptables -A INPUT -p tcp --dport 18080:18090 -s 192.168.1.0/24 -j ACCEPT

# 允许 来自 192.168.1.0/24 网段的 33 端口 到 22 端口的 tcp 包
iptables -A INPUT -p tcp --dport 22 --sport 33 -s 192.168.1.0/24 -j ACCEPT

# 允许 进入 eth1 的所有 tcp 包
iptables -A INPUT -p tcp -i eth1 -j ACCEPT
# 允许 进入 eth0 的所有包
iptables -A INPUT -i eth0 -j ACCEPT

# 允许来自 192.168.1.0/24 到 eth0 , 22 端口 ，tcp 包
iptables -A INPUT -p tcp --dport 22 -s 192.168.1.0/24 -i eth0 -j ACCEPT

#
iptables -A OUTPUT -p tcp --dport 22 -s 192.168.1.0/24 -o eth0 -j ACCEPT

```

注意： `--sport|--dport PORT` 必须与 `-p PROTOCOL` 一起使用。
注意： `-A/-I INPUT|OUTPUT` 必须与 `-i|-o ETH` 匹配

```bash

# 允许 192.168.1.233 到 eth1 网卡 ，并且限制 每秒 10 个包
iptables -A INPUT -i eth1 -s 192.168.1.233 -m limit --limit 10/s -j ACCEPT

```


## iptables nat 端口转发规则

**通常内网到外网是pre，内网到内网是post** ，但是外还是内只是个相对概念，在一定条件下是可以转换的。
落实到网卡上，对于每个网卡**数据流入的时候必然经过pre，数据流出必然经过post**。


实际应用中，简单概括一下就是：

+ PREROUTING:  内网向外网提供服务。修改 DNAT
+ POSTROUTING: 共享上网。修改 SNAT

### tips

数据包结构 ：` [ S_IP:S_PORT | D_IP:D_PORT ] `

> ip_tables: DNAT target: used from hooks POSTROUTING, but only usable from PREROUTING/OUTPUT
>
> ip_tables: SNAT target: used from hooks PREROUTING, but only usable from POSTROUTING
>
> ip_tables: MASQUERADE target: used from hooks PREROUTING, but only usable from POSTROUTING
>
> 使用 ` dmesg ` 可以查看配置错误信息

注意： `-A POSTROUTING` 不能与 `-i ETH` 搭配使用，可以与 `-o, -d ,-s ` 搭配使用

注意： `-A PREROUTING` 不能与 `-o ETH` 搭配使用，可以与 `-i, -d ,-s ` 搭配使用

### POSTROUTING

+ 可以搭配 `-o ETH` , `-s|-d IP/MASK`
+ 可以搭配 `-j SNAT` 或 `-j MASQUERADE`

+ 不能搭配 `-i ETH`
+ 不能搭配 `-j DNAT`

### PREROUTING

+ 可以搭配 `-i ETH` , `-s|-d IP/MASK`
+ 只能搭配 `-j DNAT`

+ 不能搭配 `-o ETH`
+ 不能搭配 `-j SNAT 或 -j MASQUERADE`


```bash

# PREROUTING

数据包结构 ： [ S_IP:S_PORT | D_IP:D_PORT ]

# 将到本机的数据包中，D_IP 为 61.100.1.200 的数据包的目标地址修改为 192.168.1.200。
# 该规则实现了将局域网内主机暴露在公网。对外提供服务
### [ S_IP:S_PORT | 61.100.1.200:D_PORT ] -> [ S_IP:S_PORT | 192.168.1.200:D_PORT ]
iptables -t nat -A PREROUTING -d 61.100.1.200 -j DNAT 192.168.1.200  
iptables -t nat -A PREROUTING -d 202.96.129.5 -j DNAT 192.168.1.2

# 将经过 eth1 流入的数据包目标地址改为 192.168.1.2
iptables -t nat -A PREROUTING -i eth1 -j DNAT --to 192.168.1.2

# 将来自于 192.168.1.0/24 的数据包的目标地址修改为 192.168.1.2
iptables -t nat -A PREROUTING -s 192.168.1.0/24 -j DNAT --to 192.168.1.2

# 将目标地址为 192.168.1.0/24 的数据包的目标地址修改为 192.168.1.2
iptables -t nat -A PREROUTING -d 192.168.1.0/24 -j DNAT --to 192.168.1.2
```


```bash

# POSTROUTING

数据包结构 ： [ S_IP:S_PORT | D_IP:D_PORT ]

# 将数据包中 S_IP 为 192.168.1.0/24 的地址修改为 61.100.1.200 （注意 61.100.1.200 为路由器出口IP）
# 该命令实现了局域网主机共享出口上网
### [ 192.168.1.100:S_PORT | D_IP:D_PORT ] -> [ 61.100.1.200:S_PORT | D_IP:D_PORT ]
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j SNAT 61.100.1.200  

# 自动伪装 MASQUERADE , 不具体指定源地址 , 让系统自动选择. 常用于非固定出口
# 将来自于 192.168.1.0/24 , 由 eth1 流出的数据包的源地址交给系统自动伪装
iptables -t nat -A POSTROUTING -o eth1 -s 192.168.1.0/24 -j MASQUERADE

# 将来自于 10.1.0.0/16 的流出数据包的源地址自动伪装
iptables -t nat -A POSTROUTING -s 10.1.0.0/16 -j MASQUERADE

# 将目标地址为 10.1.0.0/16 的流出数据包的源地址自动伪装
iptables -t nat -A POSTROUTING -d 10.1.0.0/16 -j MASQUERADE

# 将经过 eth1 流出的数据包的源地址(S_IP)修改为 202.96.129.5
iptables -t nat -A POSTROUTING -o eth1 -j SNAT --to 202.96.129.5
```

#### 参考链接


详细阅读：

+ http://www.cnblogs.com/ggjucheng/archive/2012/08/19/2646466.html
+ http://gaodi2002.blog.163.com/blog/static/2320768200702115132683/
+ http://www.jianshu.com/p/c2aee2ff7bd8
+ http://blog.csdn.net/reyleon/article/details/12976341

> 注意：参考链接中的命令可能有错，最好自己手动修改。
