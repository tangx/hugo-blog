---
date: "2021-09-18T00:00:00Z"
description: 创建 gitlab shell runner
featuredImagePreview: /assets/topic/gitlab.png
keywords: keyword1, keyword2
tags:
- gitlab
title: gitlab shell runner
typora-root-url: ../../
---

# 快速创建 gitlab shell runner

真没想道有一天， 我居然会创建 `gitlab shell runner` 。 环境太难管理了

# 创建 gitlab shell runner

实话实说， gitlab 现在的用户体验太好了。 根本不需要到处去搜文档，直接在 `runner` 管理界面就可以找到， 还贴心的给你准备了全套， 一键复制粘贴搞定。

https://git.example.com/admin/runners

![image-20210918114842331](/assets/img/post/2021/2021-09-18-gitlab-shell-runner/image-20210918114842331.png)



点击 `Show Runner installation instructions` 可以看到多种 runner 的配置。



在默认的基础上， 根据实际情况优化一下。

```bash
# Download the binary for your system
sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

# Give it permissions to execute
sudo chmod +x /usr/local/bin/gitlab-runner

# Create a GitLab CI user, 如果需要使用非 root 账户就创建该用户
# sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

# Install and run as service
#  /mnt/disk/gitlab-runner 工作目录需要提前建好，否则会报错
#  --user=root 表示运行账户
#  --working-directory 工作目录， 工作目录需要提前创建， 否则启动启动被错 
sudo mkdir -p /mnt/disk/gitlab-runner
sudo gitlab-runner install --user=root --working-directory=/mnt/disk/gitlab-runner

## 先不启动， 配置
# sudo gitlab-runner start
```

`install` 之后， 以后可以在 `/etc/systemd/system/gitlab-runner.service` 找到 `servcie` 的相关变更配置。

## 注册 runner

```
sudo gitlab-runner register --url https://git.example.com/ --registration-token $REGISTRATION_TOKEN
```

注册之后， 可以在 `/etc/gitlab-runner/config.toml` 变更相关配置

这里， 设置一下相关并行参数 

```toml
concurrent = 10  ## 同时允许 10 个并行 job
check_interval = 0  ## job 存在检测间隔， 默认为 3s。 小于3的值都使用默认值

# ... other
```

## 启动

```bash
systemctl daemon-reload
systemctl restart gitlab-runner
```

## 排错

```bash
journalctl -xeu gitlab-runner


Sep 18 11:28:20 aisys-dev gitlab-runner[19693]: FATAL: Service run failed                           error=chdir /mnt/disk/gitlab-runner: no such file or directory
Sep 18 11:28:20 aisys-dev systemd[1]: gitlab-runner.service: Main process exited, code=exited, status=1/FAILURE
Sep 18 11:28:20 aisys-dev systemd[1]: gitlab-runner.service: Failed with result 'exit-code'.
```

