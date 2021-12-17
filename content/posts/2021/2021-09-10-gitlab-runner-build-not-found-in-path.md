---
date: "2021-09-10T00:00:00Z"
description: gitlab-runner-build executable file not found in PATH
keywords: gitlab, runner
tags:
- gitlab
title: gitlab-runner-build not found in path
typora-root-url: ../../
---



#  `"gitlab-runner-build": executable file not found in $PATH`



在搭建 `gitlab-runner` 的过程中，报错如下

```bash
ERROR: Job failed (system failure): prepare environment: Error response from daemon: OCI runtime create failed: container_linux.go:370: starting container process caused: exec: "gitlab-runner-build": executable file not found in $PATH: unknown (exec.go:57:0s). Check https://docs.gitlab.com/runner/shells/index.html#shell-profile-loading for more information
```



因为在 `environment`  中 **扩展了** `PATH` 而导致 `gitlab-runner-helper` 中的 `PATH` 出现了异常。 从而导致 `gitlab-runner-build` 这个脚本（命令） 无法被找到。



## 原因分析



在 gitlab 的定义中 `environment` 的行为有两种 ， `append(扩展)  或 overwrite(覆盖)`。  记住 **覆盖** 行为就可以了。

```toml
# 这个是错误配置
########
environment = [
    "DDK_HOME=/root/atlas500",
    
		# 这里是整个 Runner 的默认定义， 在 runner-help 调度之前， 所以这里的 $PATH 值为空
    "PATH=$PATH",
    # 因此这里的 PATH 覆盖了以后运行的 runner-help 环境变量
    "PATH=$ATLAS500_CROSS_BIN:$ATLAS500_HOST_BIN:$ATLAS500_DEVICE_CROSS_BIN:$PATH",
  ]
```



## 解决方案



为了解决这个问题， 可以使用 `pre_build_script` ，build 前的执行的初始化脚本。同样可以达到设置环境变量的目录。 

由于本身是 **脚本** 所以， 可以做的事情有很多。

```toml
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
    export ATLAS500_HOST_BIN=$DDK_HOME/host/bin
    # ....

    export PATH=$ATLAS500_CROSS_BIN:$ATLAS500_HOST_BIN:$ATLAS500_DEVICE_CROSS_BIN:$PATH
  """
  
```

