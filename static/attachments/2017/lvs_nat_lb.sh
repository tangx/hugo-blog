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

