---
date: "2020-11-12T00:00:00Z"
description: 为 cephfs rgw 自定义策略
keywords: cephfs, s3
tags:
- cephfs
- s3
title: 使用 s3cmd 为 cephfs 设置 policy
---

# 使用 s3cmd 为 cephfs rgw 设置 policy

cephfs rgw 模式完全兼容 aws 的 s3v4 协议。 
因此对 cephfs rgw 的日常管理， 可以使用 `s3cmd` 命令操作。

## 策略

### 配置策略

+ `全局读策略`

```bash
# cat public-read-policy.json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "*"
  }]
}
```

### 设置策略

```bash
$ s3cmd setpolicy public-read-policy.json s3://example-bucket
```


### 查看

```bash
$ s3cmd info s3://example-bucket

s3://example-bucket/ (bucket):
   Location:  default
   Payer:     BucketOwner
   Expiration Rule: none
   policy:    {
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "*"
  }]
}

   cors:      none
   ACL:       AdminUser: FULL_CONTROL
```

### 删除策略

```
$ s3cmd delpolicy s3://example-bucket
s3://example-bucket/: Policy deleted

```