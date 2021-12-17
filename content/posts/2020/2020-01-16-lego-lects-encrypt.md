---
date: "2020-01-16T00:00:00Z"
description: 使用 lego 申请 let's encrypt 证书
keywords: tls
tags:
- tls
- nginx
title: 使用 lego 申请 let's encrypt 证书
---

# 使用 lego 申请 let's encrypt 证书

`lego` 是用来申请 `let's encrypt` 免费证书的, 现在支持多种验证方式。

以下是使用 `alidns` 解析验证。

```bash
#!/bin/bash
#
# lego-letsencrypt.sh
#

cd $(dirname $0)

which lego || {
    lego_ver=v3.7.0
    wget -c https://github.com/go-acme/lego/releases/download/${lego_ver}/lego_${lego_ver}_linux_amd64.tar.gz  -o lego.tar.gz
    tar xf lego.tar.gz
    cp -a lego /usr/local/bin/lego
}

DomainList="*.example.com,*.example.org"
EMAIL="your@email.com"
export ALICLOUD_ACCESS_KEY=LTAxxxxxx
export ALICLOUD_SECRET_KEY=yyyyyyyyyyyyyyyyy

Domains=""
for domain in ${DOMAINs//,/ }
do
{
    Domains="${Domains} --domain=${domain}"
}
done


function run()
{

    lego --email="${EMAIL}" \
        ${Domains} \
        --path=$(pwd) --dns alidns --accept-tos run
}

function renew()
{
    lego --email="${EMAIL}" \
        ${Domains} \
        --path=$(pwd) --dns alidns --accept-tos renew
}

function _usage()
{
    echo "$0 run|renew"
    exit 1
}
case $1 in 
run|renew) $1 ;;
*) _usage ;;
esac
```
