---
date: "2016-11-03T00:00:00Z"
description: docker官方文档，中文汉化项目
keywords: docker, doc
tags:
- docker
title: docker官方文档，中文汉化项目
---

# 说明

本项目根据学习进度不定时更新。
所有文章已经放在 [github](https://github.com/octowhale/doc2cn_docker) 上了。
并且通过 [gitbook](https://octowhale.gitbooks.io/doc2cn_docker/content/) 发布。


# docker官方文档，中文汉化项目
docker官方文档，中文汉化项目

## 项目简介
[项目简介](README.md)

## 第1章 安装运行与卸载
+ [C01S01 在CentOS7上使用二进制包安装](./chapter01/01-install-docker-with-centos.md)
  + [系统环境要求](./chapter01/01-install-docker-with-centos.md#系统环境要求)
  + [安装](./chapter01/01-install-docker-with-centos.md#安装)
    + [使用yum安装](./chapter01/01-install-docker-with-centos.md#使用yum安装)
    + [使用脚本安装](./chapter01/01-install-docker-with-centos.md#使用脚本安装)
  + [设置docker daemon为开机启动](./chapter01/01-install-docker-with-centos.md#设置docker-daemon为开机启动)
  + [卸载](./chapter01/01-install-docker-with-centos.md#卸载)
+ [C01S02 使用二进制文件安装docker](./chapter01/02-installation-from-binaries.md)


## 第2章 使用Docker
+ [C02S01 理解镜像与容器](./chapter02/01-learn-about-images-containers.md)
+ [C02S02 查找并运行镜像](./chapter02/02-find-and-run-the-whalesay-image.md)
+ C02S03 创建自定义镜像
  + [C02S03.1 使用dockerfile创建镜像](./chapter02/03-build-your-own-image-with-dockerfile.md)
  + [C02S03.2 使用commit提交容器创建镜像](./chapter02/03-build-your-own-image-with-commit.md)
  + [C02S03.3 使用import导入备份创建镜像](./chapter02/03-build-your-own-image-with-import.md)
+ [C02S04 标记、推送、下载(tag-push-pull image)](./chapter02/04-tag-push-and-pull-your-image.md)


## 第3章 通过案例学docker
+ [C03S01 容器中的Hello World](./chapter03/01-hello-world-in-a-container.md)
+ [C03S02 运行一个简单的应用](./chapter03/02-run-a-simple-application.md)
+ [C03S03 创建自定义镜像](./chapter03/03-build-your-own-images.md)
+ [C03S04 管理容器的网络连接](./chapter03/04-network-containers.md)
+ [C03S05 管理容器的数据](./chapter03/05-manage-data-in-containers.md)
+ [C03S06 管理DockerHub中的容器](./chapter03/06-store-images-on-docker-hub.md)


## 第4章 用户使用手册
+ C04S01 Docker storage drivers
  + [01 理解镜像,容器和存储驱动器](./chapter04/docker_storage_drivers/01-understand-images-containers-and-storage-drivers.md)
+ C04S02 networking
  + [01 理解容器网络](./chapter04/networking/01-understand-docker-container-networks.md)
  + [02 使用网络命令](./chapter04/networking/02-work-with-network-commands.md)
  + [03 多主机网络--overlay网络](./chapter04/networking/03-get-started-with-multi-host-networking.md)


## 第5章 管理使用手册
  + [C05S01 docker在各种发行版中的配置与启动](./chapter05/01-configuring-and-running-docker-on-various-distributions.md)
  + [C05S02 docker自动启动(进程管理器)](./chapter05/02-automatically-start-containers.md)
  + [C05S03 在守护程序停止时保持容器运行](./chapter05/03-keep-containers-alive-during-daemon-downtime.md)
  + [C05S04 使用systemd控制和配置docker](./chapter05/04-control-and-configure-docker-with-systemd.md)
  + [C05S04 格式化输出信息参考](./chapter05/05-formatting-reference.md)
  