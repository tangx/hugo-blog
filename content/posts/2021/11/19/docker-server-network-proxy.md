---
date: "2021-11-19T00:00:00Z"
description: 设置 docker server 网络代理， 下载 gcr.io 镜像
featuredImagePreview: /assets/topic/docker.png
keywords: docker, proxy, k8s, gcr.io
tags:
- docker
title: 设置 docker server 网络代理
typora-root-url: ../../
---

如果在国内使用`docker`, 大家一般会配置各种加速器, 我一般会配置阿里云或腾讯云，还算比较稳定。

`/etc/docker/daemon.json` 配置如下

```json
{
  "registry-mirrors": [
    "https://mirror.ccs.tencentyun.com",
    "https://wlzfs4t4.mirror.aliyuncs.com"
  ],
  "bip": "169.253.32.1/24",
  "data-root": "/data/docker/var/lib/docker"
}
```



上述配置， 对 `docker.io` 的镜像加速效果很好， 但对 google 镜像的加速效果就很差了比如k8s相关的以`gcr.io`或`quay.io`开头的镜像地址。

这个时候可以考虑对 docker server 进行网络代理配置。



`/usr/lib/systemd/system/docker.service` docker 的 systemd 启动配置文件

```ini
[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
# "https://mirror.ccs.tencentyun.com",
# "https://wlzfs4t4.mirror.aliyuncs.com"
Environment=HTTP_PROXY=socks5://127.0.0.1:7890
Environment=HTTPS_PROXY=socks5://127.0.0.1:7890
Environment=NO_PROXY=localhost,127.0.0.1,mirror.ccs.tencentyun.com,wlzfs4t4.mirror.aliyuncs.com

ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
```



1. `HTTP(S)_PROXY` : 设置http代理地址(自行解决)

2. `NO_PROXY` : 设置不走代理的地址, 一般会把镜像加速地址配置进去, 这里我配置的是中科大地址



配置完成后， 重启

```bash
systemctl daemon-reload
systemctl restart docker
```



测试

```bash
docker pull gcr.io/distroless/static:nonroot

  nonroot: Pulling from distroless/static
  Digest: sha256:bca3c203cdb36f5914ab8568e4c25165643ea9b711b41a8a58b42c80a51ed609
  Status: Downloaded newer image for gcr.io/distroless/static:nonroot
  gcr.io/distroless/static:nonroot
```



