---
date: "2021-09-10T00:00:00Z"
description: docker runner 与 编译环境的大文件依赖
keywords: gitlab, runner
tags:
- gitlab
title: docker runner 配置编译环境的大文件依赖
typora-root-url: ../../
---

# docker runner 配置编译环境的大文件依赖



需求简介：

现在要做某个 arm 平台的的交叉编译环境， 交叉编译依赖和工具包大小 `5G` 左右， 特别大。 

如果按照以往的方式， 直接将 **编译依赖和工具** 直接打包到编译镜像中， 会有很多麻烦。

1. **单 layer 过大**  docker 单层 layer 限制为 5G。
2. 镜像升级迭代 **浪费空间** 。 如果镜像上层升级或者依赖变化， 整个 layer 不能复用。
3. 如果将 **编译工具** 作为 `FROM Image`， 那各种语言的镜像又要自己封装， 不能与社区同步。



![image-20210910160802780](/assets/img/post/2021/2021-09-10-gitlab-docker-runner-with-huge-build-dependence-files/image-20210910160802780.png)



为了解决以上问题，  将 **编译依赖和工具** 作为外部 **volumes** 在 **Runner JOB** 运行时通过 **只读方式挂载** ， 作为编译环境的一部分。



![image-20210910161937304](/assets/img/post/2021/2021-09-10-gitlab-docker-runner-with-huge-build-dependence-files/image-20210910161937304.png)



思路大概就是这样了。



## 注册 docker runner

这里以项目 `ATLAS500` 的交叉编译环境为例， 搭建一个 `docker runner` 。



[docker runner install](https://docs.gitlab.com/runner/install/docker.html)

> 使用 alpine 的， 默认的 lastest 镜像很大， 2Gb 左右

```bash
# register a docker runner

docker run --rm -it -v /srv/gitlab-runner/config:/etc/gitlab-runner gitlab/gitlab-runner:alpine-v14.2.0 register
```



### 配置 runner 参数

> 可以在配置文件中改

```bash

Enter the GitLab instance URL (for example, https://gitlab.com/):
https://git.example.com  # 
Enter the registration token:
XXXXXXXXXXX  #
Enter a description for the runner:
[53cbe61e3bb7]: tangxin #
Enter tags for the runner (comma-separated):
tangxin #
Registering runner... succeeded                     runner=2u1np5ag
Enter an executor: docker-ssh+machine, custom, docker, docker-ssh, shell, ssh, parallels, virtualbox, docker+machine, kubernetes:
docker #
Enter the default Docker image (for example, ruby:2.6):
alpine #
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```



### 更新 runner config 配置模版

>  配置中有一些注释

```toml
concurrent = 1
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "tangxin"
  url = "https://git.example.com"
  token = "XXXXXXXXX"
  executor = "docker"
  # environment 的设置都是字面值。 只会被解析一次。
  # `ATLAS500_HOST_BIN=$DDK_HOME/host/bin` 不会扩展为 `ATLAS500_HOST_BIN=/root/atlas500/host/bin`
  # 变量会覆盖 PATH=/path/bin:$PATH。 由于之前 PATH 未定义， 所以结果为 PATH
  environment = [
    # "PATH=$PATH",
    "DDK_HOME=/root/atlas500",
  ]

  # pre_build_script 是一个 shell script
  # """ 多行引号
  pre_build_script = """
    export ATLAS500_CROSS_BIN=$DDK_HOME/toolchains/Euler_compile_env_cross/arm/cross_compile/install/bin
    export ATLAS500_HOST_BIN=$DDK_HOME/host/bin
    export ATLAS500_HOST_LIB=$DDK_HOME/host/lib
    export ATLAS500_DEVICE_CROSS_BIN=$DDK_HOME/toolchains/aarch64-linux-gcc6.3/bin
    export LD_LIBRARY_PATH=$ATLAS500_HOST_LIB:$LD_LIBRARY_PATH
    export LC_ALL=C

    export PATH=$ATLAS500_CROSS_BIN:$ATLAS500_HOST_BIN:$ATLAS500_DEVICE_CROSS_BIN:$PATH
  """
  
  [runners.custom_build_dir]
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = false
    image = "alpine"
    # helper_image = "your gitlab runner"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    # 将宿主机上的 /root/atlas500 挂载到 job 中， ro 只读模式
    volumes = [
        "/root/atlas500:/root/atlas500:ro"
    ]
    shm_size = 0

```



+ [设置环境变量]()

+ [挂载目录](https://docs.gitlab.com/runner/configuration/advanced-configuration.html#example-2-mount-a-host-directory-as-a-data-volume)



### 使用 `docker-compose` 启动 runner

```yaml
# docker-compose.yml

version: '3.1'

services: 
  gitlab-runner:
    network_mode: host
    restart: always
    image: gitlab/gitlab-runner:alpine-v14.2.0
    # image: gitlab/gitlab-runner:v14.2.0
    volumes: 
      - /srv/gitlab-runner/config/:/etc/gitlab-runner
      # 注意这里要将 docker.sock 挂载， runner 在 ci 中才能使用 docker api 创建 job
      - /var/run/docker.sock:/var/run/docker.sock

```



## 测试 CI

正常搞就可以了。

