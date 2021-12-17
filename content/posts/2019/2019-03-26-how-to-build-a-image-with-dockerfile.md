---
date: "2019-03-26T00:00:00Z"
description: 使用Dockerfile构建优质镜像
keywords: docker, image
tags:
- docker
title: 使用 Dockerfile 构建镜像注意事项
---

# 怎样去构建一个优质的Docker容器镜像

抛砖引玉

## 先说结论

1. 以不变应万变
    + 一个相对固定的 `build` 环境
    + 善用 `cache`
    + 构建 `自己的基础镜像`

2. 精简为美
    + 使用 `.dockerignore` 保持 `context` 干净
    + 容器镜像环境清理
        + 缓存清理
        + `multi stage build`

**你需要的了解的参考资料**

+ `docker storage driver`: https://docs.docker.com/storage/storagedriver/
+ `dockerfile best practices`: https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
+ `multi-stage`: https://docs.docker.com/develop/develop-images/multistage-build/

## 为什么要优化镜像

+ **一个小镜像有什么好处**: 分发更快，存储更少，加载更快。
+ **镜像臃肿带来了什么问题**: 存储过多，分发更慢且浪费带宽更多。

### 镜像的构成

![image](https://user-gold-cdn.xitu.io/2019/3/26/169b7c6cc88c5d31?w=675&h=469&f=jpeg&s=46046)

+ **俯瞰镜像**: 就是一个删减版的操作系统。
+ **侧看镜像**: 由一层层的 `layer` 堆叠而成

## 那么问题来了

0. 是否层数少的镜像, 就是一个好镜像？
1. 在企业应用中, 要怎么去规划和建设 `CI中的镜像和构建` ?
2. 带集群足够大, 节点足够多的时候, 要怎么快速分发这些镜像 ?

## 举个例子 docker build

+ **Dockerfile v1**

```Dockerfile
# v1
FROM nginx:1.15-alpine

RUN echo "hello"

RUN echo "demo best practise"

ENTRYPOINT [ "/bin/sh" ]
```

+ **Dockerfile v2**

```Dockerfile
# v2
FROM nginx:1.15-alpine

RUN echo "hello"

RUN echo "demo best practise 02"

ENTRYPOINT [ "/bin/sh" ]
```

### 1st build

全新构建

```bash
# docker build -t demo:0.0.1 .                          
Sending build context to Docker daemon  2.048kB
Step 1/4 : FROM nginx:1.15-alpine
 ---> 9a2868cac230
Step 2/4 : RUN echo "hello"
 ---> Running in d301b4b3ed55
hello
Removing intermediate container d301b4b3ed55
 ---> 6dd2a7773bbc
Step 3/4 : RUN echo "demo best practise"
 ---> Running in e3084037668e
demo best practise
Removing intermediate container e3084037668e
 ---> 4588ecf9837a
Step 4/4 : ENTRYPOINT [ "/bin/sh" ]
 ---> Running in d63f460347ff
Removing intermediate container d63f460347ff
 ---> 77b52d828f21
Successfully built 77b52d828f21
Successfully tagged demo:0.0.1
```

### 2nd build

Dockerfile 与 `1st build` 完全一致， 命令仅修改 build tag , 从 `0.0.1` 到 `0.0.2`

```bash
# docker build -t demo:0.0.2 .
Sending build context to Docker daemon  4.096kB
Step 1/4 : FROM nginx:1.15-alpine
 ---> 9a2868cac230
Step 2/4 : RUN echo "hello"
 ---> Using cache
 ---> 6dd2a7773bbc
Step 3/4 : RUN echo "demo best practise"
 ---> Using cache
 ---> 4588ecf9837a
Step 4/4 : ENTRYPOINT [ "/bin/sh" ]
 ---> Using cache
 ---> 77b52d828f21
Successfully built 77b52d828f21
Successfully tagged demo:0.0.2
```

可以看到，
1. 每层 layer 都使用 cache (` ---> Using cache`) ，并未重新构建。 
2. 我们可以通过 `docker image ls |grep demo` 看到， `demo:0.0.1` 与 `demo:0.0.2` 的 layer hash 是相同。 所以从根本上来说， 这两个镜像就是同一个镜像，虽然都是 build 出来的。


### 3rd build

这次， 我们将第三层 `RUN echo "demo best practise"` 变更为 `RUN echo "demo best practise 02"`

```bash
docker build -t demo:0.0.3 .
Sending build context to Docker daemon  4.608kB
Step 1/4 : FROM nginx:1.15-alpine
 ---> 9a2868cac230
Step 2/4 : RUN echo "hello"
 ---> Using cache
 ---> 6dd2a7773bbc
Step 3/4 : RUN echo "demo best practise 02"
 ---> Running in c55f94e217bd
demo best practise 02
Removing intermediate container c55f94e217bd
 ---> 46992ea04f49
Step 4/4 : ENTRYPOINT [ "/bin/sh" ]
 ---> Running in f176830cf445
Removing intermediate container f176830cf445
 ---> 2e2043b7f3cb
Successfully built 2e2043b7f3cb
Successfully tagged demo:0.0.3
```

可以看到 ，
1. 第二层仍然使用 `cache`
2. 但是第三层已经生成了新的 hash 了
3. 虽然第四层的操作没有变更，但是由于上层的镜像已经变化了，所以第四层本身也发生了变化。

> 注意: 每层在 `build` 的时候都是依赖于上册 ` ---> Running in f176830cf445`。

### 4th build

第四次构建， 这次使用 `--no-cache` 不使用缓存， 模拟在另一台电脑上进行 build 。

```bash
# docker build -t demo:0.0.4 --no-cache .  
Sending build context to Docker daemon  5.632kB
Step 1/4 : FROM nginx:1.15-alpine
 ---> 9a2868cac230
Step 2/4 : RUN echo "hello"
 ---> Running in 7ecbed95c4cd
hello
Removing intermediate container 7ecbed95c4cd
 ---> a1c998781f2e
Step 3/4 : RUN echo "demo best practise 02"
 ---> Running in e90dae9440c2
demo best practise 02
Removing intermediate container e90dae9440c2
 ---> 09bf3b4238b8
Step 4/4 : ENTRYPOINT [ "/bin/sh" ]
 ---> Running in 2ec19670cb14
Removing intermediate container 2ec19670cb14
 ---> 9a552fa08f73
Successfully built 9a552fa08f73
Successfully tagged demo:0.0.4
```

可以看到， 
1. 虽然和 `3rd build` 使用的 `Dockerfile` 相同， 但由于没有缓存，每一层都是重新 build 的。
2. 虽然 `demo:0.0.3` 和 `demo:0.0.4` 在功能上是一致的。但是 **他们的 layer 不同， 从根本上来说，他们是不同的镜像。**
