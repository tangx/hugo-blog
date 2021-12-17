---
date: "2020-04-26T00:00:00Z"
description: harbor 使用 s3v4 兼容模式对象存储保存数据。
keywords: s3, harbor, docker
tags:
- s3
- docker
title: harbor 使用 s3v4 兼容模式对象存储保存数据
---

# harbor使用 s3v4 兼容模式的对象存储数据

`harbor v2.0.0` 测试通过

### qingcloud qingstor

```yaml
# The default data volume
data_volume: /data

# Harbor Storage settings by default is using /data dir on local filesystem
# Uncomment storage_service setting If you want to using external storage
# storage_service:
#   # ca_bundle is the path to the custom root ca certificate, which will be injected into the truststore
#   # of registry's and chart repository's containers.  This is usually needed when the user hosts a internal storage with self signed certificate.
#   ca_bundle:

#   # storage backend, default is filesystem, options include filesystem, azure, gcs, s3, swift and oss
#   # for more info about this configuration please refer https://docs.docker.com/registry/configuration/
#   filesystem:
#     maxthreads: 100
#   # set disable to true when you want to disable registry redirect
#   redirect:
#     disabled: false

storage_service:
  s3:
    accesskey: ACID_XXXXXXXXXXXXXXX
    secretkey: ACKEY_YYYYYYYYYYYYYYY
    region: pek3b
    regionendpoint: https://s3.pek3b.qingstor.com
    bucket: harbor
    encrypt: true
    # keyid: mykeyid
    secure: true
    v4auth: true
    chunksize: 5242880
    multipartcopychunksize: 33554432
    multipartcopymaxconcurrency: 100
    multipartcopythresholdsize: 33554432
    rootdirectory: /your/path/to/storage
```

### huawei obs

```yaml
# https://docs.docker.com/registry/storage-drivers/s3/
storage_service:
  s3:
    accesskey: XXXXXXXXXX
    secretkey: YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
    region: cn-north-4
    regionendpoint: https://obs.cn-north-4.myhuaweicloud.com
    bucket: bucket_name
    ## encrypt must be fasle , huawei obs does not support this
    encrypt: false
    # keyid: mykeyid
    secure: true
    v4auth: true
    chunksize: 5242880
    multipartcopychunksize: 33554432
    multipartcopymaxconcurrency: 100
    multipartcopythresholdsize: 33554432
    rootdirectory: /registry/
```