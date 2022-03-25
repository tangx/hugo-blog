---
title: "使用 systemd 启动 hbase master 和 regionserver"
subtitle: "Manage Hbase by Systemd"
date: 2022-03-25T18:48:08+08:00
lastmod: 2022-03-25T18:48:08+08:00
draft: false
author: ""
authorLink: ""
description: ""

tags: []
categories: []

hiddenFromHomePage: false
hiddenFromSearch: false

featuredImage: ""
featuredImagePreview: ""

toc:
  enable: true
math:
  enable: false
lightgallery: false
license: ""
---



在使用 systemd 管理 HMaster 和 HRegionServer 的时候， 设置启动命令需要使用 `foregrand_start` 前台启动方式。 否则程序会自动退出。

```ini

# hbase-master.service.j2

[Unit]
Description=hbase master

[Service]
User={{ username }}
Group={{ username }}
Environment="JAVA_HOME=/data/bigdata/java"
Environment="HBASE_HOME={{ HBASE_DIR }}/hbase"
WorkingDirectory={{ HBASE_DIR }}/hbase
ExecStart={{ HBASE_DIR }}/hbase/bin/hbase-daemon.sh --config {{ HBASE_DIR }}/hbase/conf foreground_start master
ExecStop={{ HBASE_DIR }}/hbase/bin/hbase-daemon.sh  --config {{ HBASE_DIR }}/hbase/conf stop  master

Restart=on-success
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=hbase-master

[Install]
WantedBy=multi-user.target
```


在前后台启动这一点上，  `systemd` , `supervisor` 和 `docker entrypoint` 上是一样的。

