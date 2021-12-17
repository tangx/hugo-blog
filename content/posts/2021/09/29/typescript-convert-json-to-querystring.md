---
date: "2021-09-29T00:00:00Z"
description: typescript 将 json 序列化为 querystring 格式
img: null
keywords: json, querystring
tags:
- typescript
title: typescript 将 json 序列化为 querystring 格式
typora-root-url: ../../
---

# typescript 将 json 序列化为 querystring 格式



使用 typescript 时， 需要同时安装 `@types/qs` 和 `qs`

```bash
yarn add @types/qs qs
```



### demo

```ts
const params = qs.stringify({
    namespace: namespace,
    replicas: replicas,
})

const u = `/deployments/${name}/replicas?${params}`

console.log("Uuuuu::::", u);
// Uuuuu:::: /deployments/failed-nginx/replicas?namespace=default&replicas=3

```

