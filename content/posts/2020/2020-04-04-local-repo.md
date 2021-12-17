---
date: "2020-04-04T00:00:00Z"
description: 创建 linux 本地源
keywords: linux, os, apt, yum, mirrors
tags:
- linux
- yum
- apt
- repo
title: linux 创建本地源
---


# linux 创建本地源

## ubuntu 创建 local repo

将包放在 debs 目录下, 使用如下命令创建 私有仓库索引

```bash

cd /data/repo 
dpkg-scanpackages debs/ /dev/null |gzip > debs/Packages.gz

```
## centos 创建 local repo

将包放在 /data/repo/centos7 目录下, 使用如下命令创建 私有仓库索引


```bash
cd /data/repo/centos7

createrepo .
```