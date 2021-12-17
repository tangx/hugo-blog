---
date: "2017-09-02T00:00:00Z"
description: LVS 负载均衡模式介绍、8种调度算法介绍简介
keywords: LVS
tags:
- system
title: LVS 基本信息介绍
---


# LVS 介绍

本来想自己画图写介绍的，结果看了官网，里面的内容更详细更直接，所以就直接看[LVS 官网 中文](http://www.linuxvirtualserver.org/zh/lvs1.html)吧。

## 三种调度算法

+ NAT 模式: [网络地址转换 Network Address Translation](#NAT-模式)
+ TUN 模式: [IP 隧道  IP Tunneling](#TUN-模式)
+ DR 模式: [直接路由 Direct Routing](#DR-模式)

更详细的介绍可以直接看官网 [LVS集群中的IP负载均衡技术](http://www.linuxvirtualserver.org/zh/lvs3.html)

这里简单的说一下三种模式的调度原理

### NAT 模式

+ 优点：
  + RS 可以是任意操作系统
  + 转发时，目标地址的 `IP 和 端口` 都可以改变。
+ 缺点：
  + 报文进入都要经过 LB， 容易成为瓶颈
  + RS 的网关必须是 LB


从以下的例子中，我们可以更详细地了解报文改写的流程。

访问Web服务的报文可能有以下的源地址和目标地址：
`| SOURCE | 202.100.1.2:3456 | DEST | 202.103.106.5:80 |`

调度器从调度列表中选出一台服务器，例如是172.16.0.3:8000。该报文会被改写为如下地址，并将它发送给选出的服务器。
`| SOURCE | 202.100.1.2:3456 | DEST | 172.16.0.3:8000 |`

从服务器返回到调度器的响应报文如下：
`| SOURCE | 172.16.0.3:8000 | DEST | 202.100.1.2:3456 |`

响应报文的源地址会被改写为虚拟服务的地址，再将报文发送给客户：
`| SOURCE | *202.103.106.5:80* | DEST | 202.100.1.2:3456 |`

** 具体步骤如下 **

| 步骤 | 源 | 地址 | 目标 | 地址 |
| -- | -- | -- | -- | -- |
| 客户访问 LB | SOURCE | 202.100.1.2:3456 | DEST | **202.103.106.5:80** |
| LB 修改目标地址和端口为 RS 信息 | SOURCE | 202.100.1.2:3456 | DEST | **172.16.0.3:8000** |
| RS 返回包给 LB | SOURCE | *172.16.0.3:8000* | DEST | 202.100.1.2:3456 |
| LB 修改源地址和端口为 LB 信息 | SOURCE | *202.103.106.5:80* | DEST | 202.100.1.2:3456 |


![NAT 模式](http://www.linuxvirtualserver.org/zh/lvs3/vs-nat.jpg)


### TUN 模式

+ 优点：
  + RS 与 LB 可以不处于同一个网络，即支持 LAN/WAN
  + LB 处理回发报文，可以调度更多的后端 RS
  + RS 的路由出口不必指向 LB。
+ 缺点：
  + RS 必须支持 IP Tunneling
  + 不支持端口改变

LB 调度器根据各个 RS 服务器的负载情况，动态地选择一台 RS， 将**请求报文封装在另一个IP报文中**，再将封装后的IP报文转发给选出的 RS 服务器；
RS 服务器收到报文后，先将报文解封获得原来目标地址为VIP的报文，服务器发 现**VIP地址被配置在本地的IP隧道设备**上，所以就处理这个请求，然后根据路由表将响应报文直接返回给客户。

| 步骤 | 源 | 地址 | 目标 | 地址 |
| -- | -- | -- | -- | -- |
| 客户访问 LB | SOURCE | 202.100.1.2:80 | DEST | **202.103.106.5:80** |
| LB 封装报文 | SOURCE | 202.100.1.2:80 | DEST | `172.16.0.3`[**202.103.106.5:80**] |
| RS 处理后直接发送给客户端 | SOURCE | **202.103.106.5:80** | DEST | 202.100.1.2:80 |

![IP TUN flow](http://www.linuxvirtualserver.org/zh/lvs3/vs-tun-flow.jpg)

![IP TUN](http://www.linuxvirtualserver.org/zh/lvs3/vs-tun.jpg)


### DR 模式

通过直接路由实现虚拟服务器

+ 优点：
  + 吞吐量高
  + RS 路由不用指向 LB

+ 缺点：
  + 只能在 LAN 环境
  + 修改报文MAC地址转发，设备不能做 ARP 响应
  + 不支持端口改变


| 步骤 | 源 | 地址 | 目标 | 地址 |
| -- | -- | -- | -- | -- |
| 客户访问 LB | SOURCE | 202.100.1.2:80 | DEST | **202.103.106.5:80** |
| LB 封装报文 | SOURCE | 202.100.1.2:80 | DEST | `RS_MAC_ADDR`[**202.103.106.5:80**] |
| RS 处理后直接发送给客户端 | SOURCE | **202.103.106.5:80** | DEST | 202.100.1.2:80 |

![DR WORK FLOW](http://www.linuxvirtualserver.org/zh/lvs3/vs-dr-flow.jpg)

![DR MODE](http://www.linuxvirtualserver.org/zh/lvs3/vs-dr.jpg)


## LVS 的实现


### NAT 模式配置

[LB 执行](/attachments/2017/lvs_nat_lb.sh)

```bash
#! /bin/bash
#
# lvs_nat_lb.sh
#

# director服务器上开启路由转发功能:
echo 1 > /proc/sys/net/ipv4/ip_forward
# 关闭 icmp 的重定向
echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
echo 0 > /proc/sys/net/ipv4/conf/default/send_redirects
echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects
echo 0 > /proc/sys/net/ipv4/conf/eth1/send_redirects
# director设置 nat 防火墙
iptables -t nat -F
iptables -t nat -X
iptables -t nat -A POSTROUTING -s 192.168.56.0/24 -j MASQUERADE
# director设置 ipvsadm
IPVSADM='/sbin/ipvsadm'
$IPVSADM -C

## 注册 lvs table
$IPVSADM -A -t 192.168.233.207:80 -s wrr

## 添加 RS
$IPVSADM -a -t 192.168.233.207:80 -r 192.168.56.211:80 -m -w 1
$IPVSADM -a -t 192.168.233.207:80 -r 192.168.56.210:80 -m -w 1

## 删除 RS
$IPVSADM -a -t 192.168.233.207:80 -r 192.168.56.211:80

## 更改 RS
$IPVSADM -a -t 192.168.233.207:80 -r 192.168.56.210:80 -m -w 10


## 这里注意要使用  -m 参数
### 使用 -m : Forward 模式是  Masq
### 不使用 -m : Forward 模式是 Route， 这个貌似不能用

```


[RS 执行](/attachments/2017/lvs_nat_rs.sh)

```bash
#!/bin/bash
#
#
# lvs_nat_rs.sh
#
# nat 模式下， rs 只需要把网关设置为 LB 即可
#

lb_intip=192.168.56.206

route del default
route add default $lb_intip

```



### DR 模式配置

[LB 执行脚本](/attachments/2017/lvs_dr_lb.sh)

```bash
#!/bin/bash
#
# lvs_dr_lb.sh
# LB 脚本
#
# -g 参数表示 DR 模式
#

echo 1 > /proc/sys/net/ipv4/ip_forward
ipv=/sbin/ipvsadm
vip=192.168.56.233
rs1=192.168.56.204

ifconfig eth0:0 down
ifconfig eth0:0 $vip broadcast $vip netmask 255.255.255.255 up
route add -host $vip dev eth0:0
$ipv -C
$ipv -A -t $vip:80 -s wrr
$ipv -a -t $vip:80 -r $rs1:80 -g -w 3

```


[RS 执行脚本](/attachments/2017/lvs_dr_rs.sh)

```bash

#!/bin/bash
#
# lvs_dr_rs.sh
#
# RS 需要绑定 vip 和 关闭 arp 应答

vip=192.168.56.206
ifconfig lo:0 $vip broadcast $vip netmask 255.255.255.255 up
route add -host $vip lo:0

echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce

```

## LVS 基本命令介绍

```bash
# ipvs -A -t|u|f service-address [-s scheduler]
# ipvs -a -t|u|f service-address -r realserver-address  -g|i|m [-w weight]

选项说明：

##

-A|D|E : 集群服务规则配置
-a|d|e : RS 路由规则配置

-A|-a : 增加规则
-D|-d : 删除规则
-E|-e : 修改规则

##

-t|u|f service-address：事先定义好的某集群服务

-t: TCP协议
-u: UDP协议
    service-address:     IP:PORT
-f: FWM: 防火墙标记
    service-address: Mark Number


##
-s scheduler: 调度方式
# 静态调度
  rr: 轮询
  wrr: 加权轮询
  sh: 源地址哈希
  dh: 目标地址哈希
# 动态调度
  lc: 最小连接
  wlc: 加权最小连接
  lblc: 基于局部性的最小连接  # 用于 cache
  lblcr: 带复制的基于局部性的最小连接  # 用于热门 cache

##
-g|i|m: LVS类型   
  -g: DR
  -i: TUN
  -m: NAT

##
-r server-address: 某RS的地址，在NAT模型中，可使用IP：PORT实现端口映射；

[-w weight]: 定义服务器权重
```

#### 参考文档

+ http://www.linuxvirtualserver.org/zh/lvs1.html
+ http://www.cnblogs.com/liwei0526vip/p/6370103.html
+ http://blog.csdn.net/shudaqi2010/article/details/59065999
+ http://www.361way.com/lvs-tun/5202.html
