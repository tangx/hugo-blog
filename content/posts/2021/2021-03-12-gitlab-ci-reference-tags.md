---
date: "2021-03-12T00:00:00Z"
description: .gitlab-ci.yml 中复用配置
keywords: keyword1, keyword2
tags:
- cicd
- gitlab
title: gitlab-ci 配置复用 - reference tags
---

# gitlab-ci 配置复用 - reference tags

在 `GitLab 13.9` 中增加了一个新的关键字 `!reference`。 这个关键字可以在任意位置复用已存在的配置。

```bash
# tree

ci/setup.yml
.gitlab-ci.yml

```

+ **ci/setup.yml**

```yaml
# 以 . 开头的 job 名称为 隐藏job ， 将在 ci 中将被忽略
#  https://docs.gitlab.com/ee/ci/yaml/README.html#hide-jobs
.setup:
  image: hub-dev.rockontrol.com/docker.io/library/alpine:3.12
  script:
    - echo creating environment

```

+ **.gitlab.ci.yml**

```yaml
## 包含 ci/setup.yml 文件
include:
  - local: ci/setup.yml

stages:
  - prepare
  - run
  - clean

# 本地隐藏 job
.clean:
  image: hub-dev.rockontrol.com/docker.io/library/debian:buster-slim
  after_script:
    - echo make clean

job1:
  stage: prepare
  # 引用 setup 中的 image
  image: !reference [.setup, image]
  script:
    - !reference [.setup, script]
    - echo running my own command in job1

# 隐藏 job 将不会被执行
.job2:
  stage: run
  # 复用 setup 中的 image
  image: !reference [.setup, image]
  script:
    - echo running my own command in job2

job3:
  stage: clean
  # 复用 `job1 中复用的 image`
  image: !reference [job1, image]
  script:
    - !reference [.clean, after_script]

```


执行效果如下

![gitlab-ci-reference-tags-1.png](/assets/img/post/2021/03/12/gitlab-ci-reference-tags-1.png)


> 注意

1. `!reference` 不仅可以复用本文中的 image ， 更可以复用其他 job 中的任意字段
1. `!reference` 配合 `include` 和 `.hidden_job` 更可以实现通用配置
1. `!reference` 关键字后的数组实际就是被复用内容在 job 索引路径。 (`ex. [.clean, after_script]`， 为 `.clean` 隐藏job 的 `after_script` 命令)

