---
date: "2021-01-22T00:00:00Z"
description: kubernetes 常见问题
keywords: k8s
tags:
- k8s
title: CronJob 和 Job 的 退出 POD 数量管理
---

# `CronJob` 和 `Job` 的 Pod 退出保留时间

## cronjob

1. 可以认为 CronJob 作为定时调度器， 在正确的时间创建 Job Pod 完成任务。 在 CronJob 中， 默认
    + `.spec.successfulJobsHistoryLimit`: 保留 3 个正常退出的 Job 
    + `.spec.failedJobsHistoryLimit`: 1 个异常退出的 Job

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: zeus-cron-checkqueue
  namespace: zeus-dev
spec:
  schedule: "*/10 * * * *"
  failedJobsHistoryLimit: 1
  successfulJobsHistoryLimit: 3
  jobTemplate:
    spec:
      template:
    #   ... 略
```

> https://github.com/kubernetes/kubernetes/issues/64056

## job

除了 cronjob 管理 job 之外， job 本身也提供 `.spec.ttlSecondsAfterFinished` 进行退出管理。

1. **默认情况下** 如果 `ttlSecondsAfterFinished` 值未设置，则 TTL 控制器不会清理该 Job
2. Job pi-with-ttl 的 `ttlSecondsAfterFinished` 值为 100，则，在其结束 100 秒之后，将可以被自动删除
3. 如果 `ttlSecondsAfterFinished` 被设置为 0，则 TTL 控制器在 Job 执行结束后，立刻就可以清理该 Job 及其 Pod

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-with-ttl
spec:
  ttlSecondsAfterFinished: 100
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
```

> https://kuboard.cn/learning/k8s-intermediate/workload/wl-job/auto-cleanup.html
