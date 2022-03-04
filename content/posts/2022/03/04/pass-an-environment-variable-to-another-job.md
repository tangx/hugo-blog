---
title: "Gitlab 在不同 job 之间传递变量"
subtitle: "Pass an Environment Variable to Another Job"
date: 2022-03-04T18:44:29+08:00
lastmod: 2022-03-04T18:44:29+08:00
draft: false
author: ""
authorLink: ""
description: ""

tags: [gitlab]
categories: [gitlab]

hiddenFromHomePage: false
hiddenFromSearch: false

featuredImage: "/assets/topic/gitlab.png"
featuredImagePreview: "/assets/topic/gitlab.png"

toc:
  enable: true
math:
  enable: false
lightgallery: false
license: ""
---

在 gitlab 中， 不同 job 之间的变量是不能直接传递的。 但如果有需求， 则必须要借助 `artifacts:reports:dotenv` 实现。 

1. 在 job1 中保存在 `script` 下执行命令， 保存到 `xxx.env` 文件中。 
  + 将变量已 `k=v` 的形式保存
  + 每行一个
  + 不支持换行符

2. 使用 `artifacts:reports:dotenv` 传递文件

在后续 job 中， 会自动加载 job1 传递 `xxx.env` 中的变量键值对。 

另外如果在后续 job 中定义了同名变量，则这些变量值将被覆盖， 以 `xxx.env` 中的值优先。

> CI/CD 变量覆盖优先级参考: https://docs.gitlab.com/ee/ci/variables/#cicd-variable-precedence

```yaml
build:
  stage: build
  script:
    - echo "BUILD_VARIABLE=value_from_build_job" >> build.env
  artifacts:
    reports:
      dotenv: build.env

deploy:
  stage: deploy
  variables:
    BUILD_VARIABLE: value_from_deploy_job  # 变量被 build job 中的值覆盖
  script:
    - echo "$BUILD_VARIABLE"  # Output is: 'value_from_build_job' due to precedence
```

需要注意的是 **默认情况下** 同一个 `stage` 下的不同 `job` 是并行的。 因此需要在相同 stage 下的多个 job 之间传递变量就需要使用 `dependencies` 或 `needs` 关键字控制执行顺序。


```yaml

build:
  stage: build
  script:
    - echo "BUILD_VERSION=hello" >> build.env
  artifacts:
    reports:
      dotenv: build.env

deploy_one:
  stage: deploy
  script:
    - echo "$BUILD_VERSION"  # Output is: 'hello'
  dependencies:
    - build

```