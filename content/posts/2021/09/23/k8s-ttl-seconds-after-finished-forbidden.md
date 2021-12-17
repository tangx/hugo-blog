---
date: "2021-09-23T00:00:00Z"
description: spec.jobTemplate.spec.ttlSecondsAfterFinished, Forbidden, disabled by
  feature-gate
featuredImagePreview: /assets/topic/k8s.png
keywords: k8s
tags:
- k8s
title: K8S 使用 TTL 控制器自动清理完成的 job pod
typora-root-url: ../../
---

# K8S 使用 TTL 控制器自动清理完成的 Job Pod

最近为集群 CI 默认添加了 `.spec.ttlSecondsAfterFinished` 参数， 以便在 cronjob 和 job 运行完成后自动清理过期 pod 。

但是在 CI 的时候却失败， 报错如下。

```bash
spec.jobTemplate.spec.ttlSecondsAfterFinished: Forbidden: disabled by feature-gate
```



核查资料得知， 在 v1.21 之前， 该开关默认是关闭的。 刚好错误集群低于此版本。



##  Job TTL 控制器

K8S 提供了一个 **TTL** 控制器， 可以自动在 JOB `Complete` 或 `Failed` 之后， 经过一定时间清理 POD。

`.spec.ttlSecondsAfterFinished` 时间单位为 **秒**

+ 如果值 **N 等于0** ， 则任务完成后立即清除
+ 如果值 **N 大于0** ， 则任务完成后经过 **N** 秒

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-with-ttl
spec:
  ttlSecondsAfterFinished: 100  # 100 秒后清理
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
```



但是需要注意的是， 这个配置项 

1. **第一次** 是在 k8s v1.12 引入的， api 版本为 `alpha`。 换句话说，v1.12 之前的集群不能使用。
2. 在 `alpha` 阶段， 默认是不开启的。 需要通过设置 kube-apiserver 和 kube-controller-manager 中的 **feature-gates** 参数进行开启。 `--feature-gates="...,TTLAfterFinished=true"`
3. 在 k8s v1.21 的时候， api 版本更新为 `beta` ， 默认开启。 如果要关闭， 则需要对应修改 feature-gates 的 TTLAfterFinished 值为 `false`。



> https://v1-18.docs.kubernetes.io/docs/concepts/workloads/controllers/ttlafterfinished/
>
> https://v1-21.docs.kubernetes.io/docs/concepts/workloads/controllers/ttlafterfinished/

