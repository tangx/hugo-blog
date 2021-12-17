---
date: "2020-12-07T00:00:00Z"
description: 选择和安装 gitlab
keywords: gitlab
tags:
- gitlab
title: 5 分钟Gitlab - 安装 Gitlab
---

# 5 分钟Gitlab - 安装 Gitlab

Gitlab 是巴啦啦啦啦一大堆。 好处很多。

![gitlab-skills](/assets/img/post/2020/12/07/gitlab-skills.png)

## 选型

即使不准备付费， 也选 **GitlabEE（企业版本）**。

> 1. ee 版本免费授权
> 2. ee 版本默认开放 ce （社区版） 所有功能。 启用高级功能只需付费购买授权即可。
>> https://about.gitlab.com/install/ce-or-ee/?distro=ubuntu


## 准备

1. 准备一台虚拟机， 假设为 `ubuntu20.04` 操作系统。
2. 根据需要，挂载多个数据盘
    + 默认 `/var/opt/gitlab`
    + (建议独立) 数据库 postgres: `/var/opt/gitlab/postgresql/data`
3. 云上，可以对云硬盘开启定时快照。

## Ubuntu 安装

> https://about.gitlab.com/install/#ubuntu

**安装命令如下**

```bash

sudo apt-get update
sudo apt-get install -y curl ca-certificates tzdata

## 选装， 一般服务器都有 openssh-server 了
# sudo apt-get install -y openssh-server

curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash

sudo EXTERNAL_URL="https://git.tangx.in" apt-get install gitlab-ee

```

```log

Deprecations:
* sidekiq_cluster['experimental_queue_selector'] has been deprecated since 13.6 and will be removed in 14.0. The experimental_queue_selector option is now called queue_selector.


Notes:
It seems you haven't specified an initial root password while configuring the GitLab instance.
On your first visit to  your GitLab instance, you will be presented with a screen to set a
password for the default admin account with username `root`.

dpkg: error processing package gitlab-ee (--configure):
 installed gitlab-ee package post-installation script subprocess returned error exit status 1
Errors were encountered while processing:
 gitlab-ee
E: Sub-process /usr/bin/dpkg returned an error code (1)
```

`gitlab-ee` 已经安装好了， 但 `post-installation` 执行失败。 不影响配置使用。


## tls / https

> https://docs.gitlab.com/ee/user/project/pages/custom_domains_ssl_tls_certification/lets_encrypt_integration.html

**配置** gitlab 证书

```bash
# grep  -n ssl_certificate /etc/gitlab/gitlab.rb
1280:nginx['ssl_certificate'] = "/etc/gitlab/ssl/git.tangx.in.crt"
1281:nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/git.tangx.in.key"
```

**重启** gitlab nginx

```bash
gitlab-ctl restart nginx
```

> `let's encrypt` 证书使用 [lego](https://go-acme.github.io/lego/)

> [使用 lego 申请 let’s encrypt 证书](https://tangx.in/2020/01/16/lego-lects-encrypt/)

## 修改初始密码

浏览器登录访问， 默认用户 `root`

![change password](/assets/img/post/2020/12/07/gitlab-change-root-password.png)
