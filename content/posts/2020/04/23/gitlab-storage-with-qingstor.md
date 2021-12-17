---
date: "2020-04-23T00:00:00Z"
description: gitlab 使用青云 qingstor 对象存储作为存储。 使用 s3 compatible
keywords: minio, s3
tags:
- cate1
- cate2
title: gitlab 使用青云 qingstor 对象存储作为存储
---

# gitlab 使用青云 qingstor 对象存储作为存储

使用 `s3 compatible` 模式， **腾讯云、阿里云、华为云、青云** 都可以实现。

```ruby

# https://docs.gitlab.com/ce/administration/job_artifacts.html

gitlab_rails['artifacts_enabled'] = true
gitlab_rails['artifacts_object_store_enabled'] = true
gitlab_rails['artifacts_object_store_remote_directory'] = "gitlab-storage-artifacts"
gitlab_rails['artifacts_object_store_connection'] = {

# s3v4 compatible mode
# https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/objectstorage/rails.minio.yaml

  'provider' => 'AWS',
  'region' => 'us-east-1',
  'aws_access_key_id' => 'ACID_XXXXXXXXXXXXXXXXX',
  'aws_secret_access_key' => 'ACKEY_YYYYYYYYYYYYYYYY',
  'aws_signature_version' => 4,
  'host' => 's3.pek3b.qingstor.com',
  'endpoint' => "http://s3.pek3b.qingstor.com",
  'path_style' => true

}

```