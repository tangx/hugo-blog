---
date: "2020-11-07T00:00:00Z"
description: 使用 docker buildx 构建镜像的案例分享
keywords: docker, cpu, usage, example
tags:
- docker
title: 使用 docker buildx 实现多平台编译 - 案例篇
---

# 使用 docker buildx 实现多平台编译 - 案例篇

之前的文章中 [使用 docker buildx 实现多平台编译 - 环境篇](https://tangx.in/2020/06/10/docker-buildx/) 介绍了如何部署 docker buildx 环境。

笔者本文将要分享自身在使用中的几个比较有意义的案例

## 0x00 先说结论

1. `docker buildx` 本身运行于容器环境， 所以 **scheduler** 和 **builder** 本机配置（ex, `/etc/hosts`, `/etc/docker/daemon.json` ） 的大部分配置和场景 其实是不可用的。
1. 使用 `ssh://user@host` 可以方便的执行远程构建， 尤其是在构建最基础的镜像，需要海外镜像时。
1. `docker buildx` 现在仍然处于实验阶段，在不断的更新。 尤其是在 Dockerfile 的使用上有很多新特性， 可以参考[dockerfile experimental](https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/experimental.md)
1. 转存和合并镜像非常方便， 结合 `github action` 可以完全托管。

## 0x01 远端 builder 

之前的文章中， 我们通过 `qemu` 模拟了多架构的环境。 但实际在使用中， 在模拟架构中执行工作效率是特别低的， 如果已经执行某些项目编译， 那你就应该感同身受了。

如笔者之前维护的 opencv 双架构的项目， 通过 *github action* 进行跨平台编译， 长达三四小时。而在本架构下只需要短短的10几分钟。

![opencv-multi-arch-github-action.jpg](/assets/img/post/2020/11/07/opencv-multi-arch-github-action.jpg)

因此， 在同架构下执行编译或其他工作的需求就特别迫切了。

1. 好在 `docker buildx` 可以支持 *专机专用* - 根据机器架构执行对应的任务。 
2. 另外， `docker` 本身也支持基于 `ssh://user@host` 协议的远程调用。 通过免密码证书， 非常容易管理。

### 执行环境

假设有三台机器, 且 scheduler 能通过证书免密码登录两台 builder。

| 用途 | 主机地址 | CPU 架构 |
| -- | -- | -- |
| scheduler | 10.100.100.10 | - |
| arm64 builder | 192.168.100.101 | arm64 / aarch64 |
| amd64 builder | 192.168.100.102 | amd64 / x86_64 |

### 创建 remotebuilder

在 **scheduler(10.100.100.10)** 创建 remotebuilder , 命令如下

```bash
ARM64=ssh://root@192.168.100.101
AMD64=ssh://root@192.168.100.102

## 注意: 这里指定名称 remotebuilder
DOCKER_HOST=${AMD64} docker buildx create --name remotebuilder --node hk-amd64 --platform=amd64
### --append 表示追加， 而非重新创建
DOCKER_HOST=${ARM64} docker buildx create --append --name remotebuilder --node hk-arm64 --platform=arm64

## 使用 remotebuilder
docker buildx use remotebuilder

## 查看 remotebuilder 状态
docker buildx ls --builder remotebuilder
```

到此位置， `remote builder` 及创建成功了。 

当我们在本地执行 `docker buildx build ...` 任务的时候， 任务就会分发到对应 cpu 架构的主机上。

### 执行镜像构建

1. 创建 Dockerfile

这里 `Dockerfile` 非常简单， 仅仅就是拉取 `centos:8` 镜像。

```bash
mkdir -p centos/ && cd centos/ 
echo "FROM centos:8" > Dockerfile
tree
    # .
    # └── Dockerfile

    # 0 directories, 1 file
```

2. 使用 `docker buildx` 命令拉取镜像。

> 注意: 这里我们没有使用 `--tag` 指定目标镜像名称。

```bash
docker buildx build --platform=linux/amd64,linux/arm64 .
```

![remote-builder.jpg](/assets/img/post/2020/11/07/remote-builder.jpg)

3. 重新执行 `docker buildx` 命令。

> 注意: 这次我们使用了 `--tag` 和 `--push`， 在构建完成后，会推送到目标 `docker registry`

> 注意2: 如果要执行 `--push` 成功， 只需要在 **scheduler** 主机上执行 `docker login` 即可， **builder** 上并无登录需求。

```bash
docker buildx build --platform=linux/amd64,linux/arm64 --tag tangx/centos:8 --push .
```

![remote-builder.jpg](/assets/img/post/2020/11/07/remote-build-push.jpg)

注意红框位置， 这次直接结果 ， 多了 `exporting` 和 `merging`

当任务执行换成之后，所构建的 `layer` 缓存会存在与 **`remote builder`** 上， 同时 **scheduler** 上会保存多架构的 manifest 信息。

输出结果 [tangx/centos:8](https://hub.docker.com/r/tangx/centos/tags) 可以在 dockerhub 上看到。


## 0x02 配置优化

在国内使用 `docker buildx` 有一个最大的问题，就是网络。 

由于 `driver` 是有运行在容器中， 参考官方文档 [buildx - github.com](https://github.com/docker/buildx/blob/master/README.md#buildx-create-options-contextendpoint)， 很多本机的配置因此而不能生效。 

诸如 `docker.io` 这样国外官方镜像， 拉取速度就非常不理想了。


### 使用镜像加速优化

1. 新建配置文件 `buildkitd.toml` 

```toml
# buildkitd.toml
[registry."docker.io"]
  mirrors = ["wlzfs4t4.mirror.aliyuncs.com"]
```

并创建本地 `builder`

```bash
### create builder with mirror
docker buildx create --use --name localbuilder --platform=linux/amd64,linux/arm64 --config=buildkitd.toml
```

2. 新建 `Dockerfile`

```Dockerfile
# Dockerfile
FROM centos:8
```

并构建镜像

```
### build a image
docker buildx build --platform=linux/amd64,linux/arm64 .
```

![builder-with-mirror.png](/assets/img/post/2020/11/07/builder-with-mirror.png)

结果如上图所示， 耗时约 14s 左右

### 使用默认参数，不使用镜像优化

1. 创建不使用镜像优化的 mirror， 并执行构建

```bash
### without mirror
docker buildx create --use --name localbuilder-no-mirror --platform=linux/amd64,linux/arm64 

### build a image
docker buildx build --platform=linux/amd64,linux/arm64 .
```

![builder-without-mirror.png](/assets/img/post/2020/11/07/builder-without-mirror.png)

从图片中可以看到， 在没有 mirror 的情况下， 出现了网络问题。

> 这是因为 builder 运行在容器类， 并没有使用宿主机的 `/etc/docker/daemon.json` 配置 (**假设宿主机已经配置了 mirror**), 即相当于国内**直连 `docker.io`** 拉去镜像。


## 0x03 Dockerfile 案例

如果你实现阅读了 [Dockerfile `ARG` 使用及作用域的分析](https://tangx.in/2020/11/06/dockerfiles-args-scope/) ， 那么以下两个 `Dockerfile` 就很简单了。

### sync

**唯一作用: 对镜像重命名**, 通过参数的方式实现了不通镜像的同步。

```Dockerfile
ARG IMAGE
FROM ${IMAGE}
```

```bash
image=tangx/alpine
tag=3.12

docker buildx build --platform=linux/amd64,linux/arm64 \
  --tag ${image}:${tag} \
  --file Dockerfile
  --build-arg IMAGE=alpine:3.12 \
  .
```

### combine

这里通过 **多阶** 构建中 `别名` 及 `${TARGETARCH}` 的方式， 将两个独立 tag 镜像合并成一个。
例如 [`minio/minio`](https://hub.docker.com/r/minio/minio/tags) 的镜像。

```Dockerfile

FROM example.com/alpine:3.12-arm64 as arm64
FROM example.com/alpine:3.12-amd64 as amd64

FROM ${TARGETARCH}

```

> 注意， 
>> 1. `TARGETARCH` 在 `FROM` 中使用不需要预先声明 `ARG TARGETARCH` 。 
>> 2. `TARGETARCH` 在 body 中使用必须预先声明 `ARG TARGETARCH` 。 


```bash
docker buildx build --platform=linux/amd64,linux/arm64 \
  --tag example.in/alpine:3.12 \
  --file Dockerfile
  --build-arg IMAGE=alpine:3.12 \
  .
```
