---
date: "2020-11-06T00:00:00Z"
description: Dockerfile 中 ARG 的使用与其的作用域探究
keywords: docker, image
tags:
- docker
- container
title: Dockerfile 中 ARG 的使用与其的作用域探究
---

# Dockerfile 中 ARG 的使用与其的作用域探究

使用 `ARG` 可以有效的复用 Dockerfile。 每次镜像更新，只需要动态的在 `build` 命令中传入新的参数值即可。


## 0x01 结论

1. 在第一个 `FROM` 之前的所有 ARG , 在所有 `FROM` 中生效, 仅在 `FROM` 中生效
2. 在 `FROM` 后的 `ARG`, 仅在当前 `FROM` 作用域生效。 即尽在当前 **阶段 (stage)** 生效

### 对照组解析

在随后的 Dockerfile 中, 只定义了一个变量 `image` , 并在 `FROM` 和 **stage** 中重复使用

1. 对照组1: `stage1` 和 `stage11` 均在 `FROM` 中使用了变量 `$image`: **作用域在所有 `FROM` 中
    + 成功拉取 `FROM $image` 并完成 layer 构建
    + 但是在 `RUN` 中无法正确输出结果，即 **image** 的值 *alpine:3.12*

2. 对照组2: `stage1` vs `stage2`: **作用域在 FROM stage 内部**
  + 在 `stage2` 的作用域中声明了 `ARG image`，且能正确输出结果。

3. 对照组3: `stage2` vs `stage21`: 作用域**仅在当前** `FROM stage` 内部
    + 虽然 `stage2` 在 `stage21` 上方且声明了 `ARG image`， 但 `stage21` 仍然不能不能正确输出结果。

## 0x02 实验过程

1. 创建 Dockerfile 如下

```Dockerfile

## 在第一个 FROM 之前的所有 ARG , 在所有 FROM 中生效, 仅在 FROM 中生效
ARG image

FROM $image as stage1
RUN echo "stage1 -> base from image is : $image "
    # result: stage1 -> base from image is :

FROM $image as stage11
RUN echo "stage11 -> base from image is : $image "
    # result: stage11 -> base from image is :

FROM alpine:3.12 as stage2
## 在 FROM 后的 ARG, 仅在当前 FROM 作用域生效。 即尽在当前 阶段 (stage) 生效
ARG image
RUN echo "stage2 -> base from image is : $image "
    # stage2 -> base from image is : alpine:3.12

FROM alpine:3.12 as stage21
RUN echo "stage21 -> base from image is : $image "
    # stage21 -> base from image is :


```

2. 执行 `docker build` 命令

```bash
# docker build --build-arg image=alpine:3.12 --no-cache .
```

+ `build` 结果展示

```bash
Sending build context to Docker daemon  3.072kB
Step 1/10 : ARG image
Step 2/10 : FROM $image as stage1
 ---> d6e46aa2470d
Step 3/10 : RUN echo "stage1 -> base from image is : $image "
 ---> Running in ecb7be5dd9cc
stage1 -> base from image is :  ### image 结果未输出
Removing intermediate container ecb7be5dd9cc
 ---> 04807c8d53be
Step 4/10 : FROM $image as stage11
 ---> d6e46aa2470d
Step 5/10 : RUN echo "stage11 -> base from image is : $image "
 ---> Running in a90e45076345
stage11 -> base from image is :       ### image 结果未输出
Removing intermediate container a90e45076345
 ---> f2dbce837a1b
Step 6/10 : FROM alpine:3.12 as stage2
 ---> d6e46aa2470d
Step 7/10 : ARG image
 ---> Running in 5c8cec4c2f22
Removing intermediate container 5c8cec4c2f22
 ---> 999d9990bd91
Step 8/10 : RUN echo "stage2 -> base from image is : $image "
 ---> Running in 4407dcb0e0bb
stage2 -> base from image is : alpine:3.12     ### image 结果输出
Removing intermediate container 4407dcb0e0bb
 ---> e5ddd7a84f81
Step 9/10 : FROM alpine:3.12 as stage21
 ---> d6e46aa2470d
Step 10/10 : RUN echo "stage21 -> base from image is : $image "
 ---> Running in 64a0a3bb090c
stage21 -> base from image is :      ### image 结果未输出
Removing intermediate container 64a0a3bb090c
 ---> 82665f9a1037
Successfully built 82665f9a1037
```

## 0x03 参考文档

+ [set-build-time-variables---build-arg](https://docs.docker.com/engine/reference/commandline/build/#set-build-time-variables---build-arg)

