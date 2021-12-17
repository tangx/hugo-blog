#!/bin/bash
#
# lvs_dr_lb.sh
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

