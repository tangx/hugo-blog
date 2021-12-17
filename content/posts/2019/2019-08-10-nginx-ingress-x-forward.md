---
date: "2019-08-10T00:00:00Z"
description: k8s nginx ingress 添加 x-forwarded
keywords: k8s
tags:
- k8s
- nginx
title: k8s nginx ingress 添加 x-forwarded
---


# ingress 配置

## for-forward-for

```
The client IP address will be set based on the use of PROXY protocol or from the X-Forwarded-For header value when use-forwarded-headers is enabled.
```

> https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#use-forwarded-headers

> https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#forwarded-for-header

```yaml

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: srv-bff-op-center
  annotations:
    nginx.ingress.kubernetes.io/forwarded-for-header: "X-Forwarded-For"
    kubernetes.io/ingress.class: "nginx"
```
