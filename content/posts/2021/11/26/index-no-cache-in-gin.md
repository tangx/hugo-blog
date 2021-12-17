---
date: "2021-11-26T00:00:00Z"
description: nginx 实现首页不缓存
featuredImagePreview: topic/gin.png
keywords: cdn, nginx, cache
tags:
- cdn
- vue3
- gin
title: gin 实现首页不缓存
typora-root-url: ../../
---

# 在 gin 中实现首页不缓存

之前提到了在 nginx 中添加响应头 `Cache-Control: no-cache` 不缓存首页， 以便每次发布 CDN 都能回源到最新的资源。

nginx 的配置可能都是实施人员的操作， 或许不在掌控范围内。

自己控制起来很简单， 无非就是加一个 Header 头嘛。


```go

package main

import (
	"fmt"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	// 一定要放在最前面
	r.Use(noCacheIndex)

	r.Any("/", func(c *gin.Context) {
		c.String(200, "ok")
	})

	_ = r.Run(":8089")
}

func noCacheIndex(c *gin.Context) {
	path := c.Request.URL.Path
	// fmt.Println("path=", path)
	if path == "/" || path == "/index.html" {
		c.Header("Cache-Control", "no-cache")
	}
}
```

结果如预期

```http
HTTP/1.1 200 OK
Cache-Control: no-cache
Content-Type: text/plain; charset=utf-8
Date: Fri, 26 Nov 2021 02:50:50 GMT
Content-Length: 2
Connection: close

ok
```

