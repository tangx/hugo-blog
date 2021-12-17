---
date: "2017-07-12T00:00:00Z"
description: 为 linux 系统软件配置代理
keywords: linux
tags:
- linux
title: 为 linux 系统软件配置代理
---



# 为 linux系统软件配置 socks 和 http 代理 

## use sslocal to setup a socks5 proxy


```bash

pip install shadowsocks

sslocal --help

```


## CENTOS 6 install privoxy

> https://superuser.com/questions/452197/how-to-install-privoxy-on-centos-6

```bash

# These commands are more easier and manageable

wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -Uvh epel-release-6-8.noarch.rpm
yum install privoxy -y

# In future if you want to update

yum update privoxy -y
#  Ref: http://pkgs.org/centos-6/epel-x86_64/privoxy-3.0.21-3.el6.x86_64.rpm.html

# shareimprove this answer
```


## transfer protocol from socks to http via privoxy

> https://wiki.archlinux.org/index.php/Shadowsocks_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)

> https://blog.phpgao.com/privoxy-shadowsocks.html

方法二：
1.直接指定Chromium走socks代理似乎不能远程dns解析，这未必是用户的期望，可使用privoxy等软件转化socks代理为http代理。
编辑privoxy配置文件（不要漏下1080后面的点)

```bash
vi /etc/privoxy/config

/etc/privoxy/config
forward-socks5   /               127.0.0.1:1080 .
listen-address  127.0.0.1:8118

# 重启服务应用更改：
# /etc/init.d/privoxy restart
#2.假设转化后的http代理为127.0.0.1:8118，则在终端中启动：
# $ chromium %U --proxy-server=127.0.0.1:8118

```


## use proxy for rpm

> http://linux.ximizi.com/linux/4/31195.html

```
rpm --import https://linux-packages.resilio.com/resilio-sync/key.asc --httpproxy 127.0.0.1:9999
```

## use proxy for yum

> 注意： 在centos 6 上，yum只能使用 http, https, ftp 协议的代理。 但在 centos 7上 yum 可以使用 socks5 的代理。

```

vi /etc/yum.conf


proxy=http://127.0.0.1:9999/


```

## use proxy for curl

> https://aiezu.com/article/linux_curl_proxy_http_socks.html

```bash

curl -x http://127.0.0.1:9999 ip.cip.cc
curl -x socks5://127.0.0.1:9999 ip.cip.cc
```



## use proxy for wget

> http://www.111cn.net/sys/linux/85275.htm

```
vi /etc/wgetrc

http_proxy = http://127.0.0.1:9999/
https_proxy = http://127.0.0.1:9999/
ftp_proxy = http://127.0.0.1:9999/
use_proxy = on
wait = 15
```

当使用命令行模式的时候，https 代理会报错。

```bash
# wget --no-check-certificate -e use_proxy=yes  -e https_proxy=http:/127.0.0.1:9999 https://linux-packages.resilio.com/resilio-sync/key.asc
Error in proxy URL ftp://http//127.0.0.1:9999: Must be HTTP.
```
