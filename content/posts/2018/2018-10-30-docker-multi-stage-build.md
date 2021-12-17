---
date: "2018-10-30T00:00:00Z"
description: Docker多阶构建，优化镜像层级，清理空间
keywords: docker
tags:
- docker
title: docker multi-stage build
---

# Docker multi-stage build 

Multi-stage 构建，最大的好处是 Docker 本身在构建过程中提供了一个缓存空间，将上一个 `stage` 的结果通过 `COPY --from=<stage>` 复制到下一个 `stage`。
这样就大大简化了镜像清理工作。

这里， docker 官方文档已经对 [Multi-stage build](https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds) 已经有详细说明了。 

> multi-stage 要求 docker version >= 17.05


## 举例

+ 每一个 `FROM` 关键字都表示此处是一个 `stage`
+ 对 stage 使用命令的关键字是 `as` ， 例如 `FROM alpine:latest as initer`
+ 在引用 stage 时， 使用 `--from=<stage_name>` ， 例如 `COPY --from=initer /data/v2ray /usr/bin/v2ray`
  + 如果没有别名， 按照 from 的顺序，分别是 `0-N`， 例如 `--from=0`

```Dockerfile
# stage initer
FROM alpine:latest as initer

RUN apk update   \
    && apk add ca-certificates wget  \
    && update-ca-certificates  

ENV version="0.0.1-beta"      
ENV v2ray_version="v3.50.1"

WORKDIR /data
RUN wget https://github.com/v2ray/v2ray-core/releases/download/${v2ray_version}/v2ray-linux-64.zip      \
    && unzip -q v2ray-linux-64.zip  \
    && chmod +x v2ray

# stage builder
FROM alpine:latest as builder
COPY --from=initer /data/v2ray /usr/bin/v2ray

ENTRYPOINT ["/usr/bin/v2ray" ]
CMD ["-config=/etc/v2ray/config.json"]
```

