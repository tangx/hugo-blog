---
date: "2021-09-06T00:00:00Z"
description: gitlab ci 使用多个 runner 执行特定 JOB
keywords: gitlab
tags:
- gitlab
title: GitlabCI 使用多个 Runner 执行特定 JOB
typora-root-url: ../../
---

# GitlabCI 使用多个 Runner 执行特定 JOB

在 Gitlab CI 中，Runner 是 Job 的执行器， 也就是说 **Job** 的运行环境， 就是 Runner 的环境。

那么， 怎么将同一个 `gitlab ci` 中的  `Job`  运行在不同的 Runner 上呢？

例如， 根据 **操作系统** 区分， `job1` 运行在 `windows` 上， `job2` 运行在 `linux` 上， 诸如此类。



## 使用 TAG 指定 runner

其实很简单， `gitlab ci` 中， 可以通过指定 `tags` 来设定运行条件， 满足了 `tag` 才能被执行。 

而 `ci` 中的 `tags` 和可以和 `runner` 中的 `tags` 进行匹配



### `.gitlab-ci.yml`

`.gitlab-ci.yml` 文件如下， 定义了一个 `tar` stage ， 下面有 **三个** `job` 分别对应 **三个 runner** 的编译和大包环境。

> 注意， 这里使用的是 Runner 的 `TAG` ，不是 Runner 的名字

```yaml
stages:
  - tar

# .gitlab-ci.yml
tar.ivs:
  stage: tar
  script:
    - /bin/bash ivs-1800-matrix-build.sh
  tags:
    - neuron-arm64 # 执行 ivs 的runner

tar.3519a:
  stage: tar
  script:
    - /bin/bash hisi-3519a-build.sh
  tags:
    - 3519A  # 执行 3519a 的 runner


tar.atlas:
  stage: tar
  script:
    - /bin/bash atlas-500-matrix-build.sh
  tags:
    - edge # 执行 atlas 的 runner

```



### 选择 runner

在 **Project CICD** 配置中， 选中需要的的 **三个** runner。

注意红色箭头中的 `TAG` 标记， 也就是上面 `gitlab-ci.yml` 中的 `tags` 值。



![image-20210906182946316](/assets/img/post/2021/2021-09-06-gitlab-ci-under-multiple-runners/image-20210906182946316.png)



## 执行结果

CI 正常触发后， 可以看到三个 **JOB** 正常执行， 并且是在对应选择的 runner 上。



![image-20210906183155757](/assets/img/post/2021/2021-09-06-gitlab-ci-under-multiple-runners/image-20210906183155757.png)

