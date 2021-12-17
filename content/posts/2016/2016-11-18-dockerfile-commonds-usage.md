---
date: "2016-11-18T00:00:00Z"
description: Dockerfile 基础命令
keywords: docker, 基础命令
tags:
- docker
title: Dockerfile 基础命令
---


# Dockerfile 基础命令

Dockerfile 有十几条命令可用于构建镜像，下文将简略介绍这些命令。


## FROM

FROM 命令可能是最重要的 Dockerfile 命令。改命令定义了使用哪个基础镜像启动构建流程。基础镜像可以为任意镜像。如果基础镜像没有被发现， Docker 将试图从 Docker image index 来查找该镜像。FROM 命令必须是Dockerfile的首个命令。

```
# Usage: FROM [image name]
# FROM 之前可以有注释行
FROM ubuntu
```

## MAINTAINER

我建议这个命令放在 Dockerfile 的起始部分，虽然理论上它可以放置于 Dockerfile 的任意位置。这个命令用于声明作者，并应该放在 FROM 的后面。

```
# Usage: MAINTAINER [name]
MAINTAINER authors_name
```

## ENV 

ENV 命令用于设置环境变量。这些变量以 `key=value` 的形式存在，并可以在容器内被脚本或者程序调用。这个机制给在容器中运行应用带来了极大的便利。

```
# Usage: ENV key value
ENV SERVER_WORKS 4
```


## ADD

ADD 命令有两个参数，源和目标。它的基本作用是从源系统的文件系统上复制文件到目标容器的文件系统。如果源是一个 URL ，那该 URL 的内容将被下载并复制到容器中。

```
# Usage: ADD [source directory or URL] [destination directory]
ADD /my_app_folder /my_app_folder
```


## USER

USER 命令用于设置运行容器的 UID 。

```
# Usage: USER [UID]
USER 751
```
 

## VOLUME

VOLUME 命令用于让你的容器访问宿主机上的目录。

```
# Usage: VOLUME ["/dir_1", "/dir_2" ..]
VOLUME ["/my_files"]
```


## RUN

RUN 命令是 Dockerfile 执行命令的核心部分。它接受命令作为参数并用于创建镜像。不像 CMD 命令， RUN 命令用于创建镜像（在之前 commit 的层之上形成新的层）。

```
# Usage: RUN [command]
RUN aptitude install -y riak
```


## EXPOSE

EXPOSE 用来指定端口，使容器内的应用可以通过端口和外界交互。

```
# Usage: EXPOSE [port]
EXPOSE 8080
```


## WORKDIR

WORKDIR 命令用于设置 CMD 指明的命令的运行目录。

```
# Usage: WORKDIR /path
WORKDIR ~/
```


## CMD

和 RUN 命令相似， CMD 可以用于执行特定的命令。和 RUN 不同的是，这些命令不是在镜像构建的过程中执行的，而是在用镜像构建容器后被调用。
如果 dockerfile 中有条 CMD 命令，则只会执行最后一条。

```
# Usage 1: CMD application "argument", "argument", ..
CMD "echo" "Hello docker!"
```


## ENTRYPOINT

ENTRYPOINT 帮助你配置一个容器使之可执行化，如果你结合 CMD 命令和 ENTRYPOINT 命令，你可以从 CMD 命令中移除 `application` 而仅仅保留参数，参数将传递给 ENTRYPOINT 命令，
与 CMD 一样，如果 dockerfile 中有条 ENTRYPOINT 命令，则只会执行最后一条。

```
# Usage: ENTRYPOINT application "argument", "argument", ..
# Remember: arguments are optional. They can be provided by CMD
# or during the creation of a container.

ENTRYPOINT echo

# Usage example with CMD:
# Arguments set with CMD can be overridden during *run*

CMD "Hello docker!"
ENTRYPOINT echo

# Hello docker!
```
