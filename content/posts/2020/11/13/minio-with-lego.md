---
date: "2020-11-13T00:00:00Z"
description: lego 生成证书, minio 提供对象存储访问
keywords: minio, s3, https, tls
tags:
- minio
- s3
title: minio 使用 lego 实现 https
---

# minio 使用 lego 实现 https 访问

minio 提供两种 https 访问。

1. **推荐** 在启动过程中使用 `certs` 证书。 此种方法最后只提供 `https` 访问。

2. 使用 https 代理。 
    + [nginx proxy](https://docs.min.io/docs/setup-nginx-proxy-with-minio.html)
    + [caddy proxy](https://docs.min.io/docs/setup-caddy-proxy-with-minio.html)



```bash
$ tree . -L 3

.
├── certs
│   ├── CAs
│   ├── private.key
│   └── public.crt
├── data
├── entrypoint.sh
├── minio
```

```bash
#!/bin/bash
# entrypoint.sh

cd $(dirname $0) 
DIR=$(pwd)
export MINIO_ACCESS_KEY=minio
export MINIO_SECRET_KEY=miniostorage

./minio --certs-dir ${DIR}/certs server ${DIR}/data

```

## troubleshoot

### the ECDSA curve 'P-384' is not supported

```
ERROR Unable to load the TLS configuration: tls: the ECDSA curve 'P-384' is not supported
      > Please check your certificate
```

`minio` 默认不支持 `P-384` 算法。 生成密钥的时候， 使用其他算法即可。

> https://github.com/minio/minio/issues/7698#issuecomment-496399521

**解决方式** 

在使用 [`lego`](https://github.com/go-acme/lego) 时, 使用非默认参数。
例如添加 `--key-type rsa2048` 参数。

```bash

$ lego --help

   --key-type value, -k value   Key type to use for private keys. Supported: rsa2048, rsa4096, rsa8192, ec256, ec384. (default: "ec384")

```

+ `lego.sh` 生成证书全文如下

```bash
#!/bin/bash
#
# lego-letsencrypt.sh
#

cd $(dirname $0)

DOMAIN1="*.s3.example.com"
EMAIL="user@example.com"

export ALICLOUD_ACCESS_KEY=AKID1234567
export ALICLOUD_SECRET_KEY=AKEY1234567890

lego  --email="${EMAIL}" \
      --key-type rsa2048 \
      --domains="${DOMAIN1}" \
      --path=$(pwd) --dns alidns --accept-tos run
```


