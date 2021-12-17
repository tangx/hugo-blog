---
date: "2021-09-27T00:00:00Z"
description: gin 内部重定向时 middleware 不可用异常
image: topic/gin.png
keywords: gin
tags:
- golang
- gin
title: gin 内部重定向时 middleware 不可用异常
typora-root-url: ../../
---

# gin 内部重定向时 middleware 不可用异常

## axios 请求时出现 cors error

![image-20210928105301685](/assets/img/post/2021/2021-09-27-axios-301-redirect-cors-error/image-20210928105301685.png)

在使用 `axios` 请求后端时，遇到 **cors** 跨域问题， 虽然已经在 gin 中添加了 cors 的 **middleware**



```go
func cors() gin.HandlerFunc {
	return func(c *gin.Context) {
		method := c.Request.Method
		origin := "*"
		if method != "" {
			c.Header("Access-Control-Allow-Origin", origin) // 可将将 * 替换为指定的域名
			c.Header("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE, UPDATE")
			c.Header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization,X-Token")
			c.Header("Access-Control-Expose-Headers", "Content-Length, Access-Control-Allow-Origin, Access-Control-Allow-Headers, Cache-Control, Content-Language, Content-Type")
			c.Header("Access-Control-Allow-Credentials", "true")
		}
		if method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
		}
	}
}
```



## 问题原因

`gin Middleware` 是 gin https://github.com/gin-gonic/gin/ 中的一个概念

> https://github.com/gin-gonic/gin/#using-middleware

在使用的时候 **小心** gin 针对地址尾部的 `/` 的处理时丢失 **middleware** 逻辑的问题。

例如， 定义了一个路由 `/k8sailor/v0/deployments` 

```go
func DeploymentRouterGroup(base *gin.RouterGroup) {
	// 创建 dep 路由组
	dep := base.Group("/deployments")
	{
		// 针对 所有 deployment 操作
		dep.GET("", handlerListDeployments)
	}
}
```

在请求的时候， 访问 `/k8sailor/v0/deployments/` ， 那么 gin 将自动 301 重定向到 `/k8sailor/v0/deployments`

内部 301 日志如下

![image-20210928105434410](/assets/img/post/2021/2021-09-27-axios-301-redirect-cors-error/image-20210928105434410.png)

1. 该重定向不是常规的给客户端返回 **301和 Location** 再由客户端发起的。而是直接在 gin 内部就完成了。

![image-20210928110155018](/assets/img/post/2021/2021-09-27-axios-301-redirect-cors-error/image-20210928110155018.png)

​	从 **network 瀑布** 可以看到， 客户端只向服务端发送了 **一次** 请求。

1. 该重定向不会携带 **gin middlware** 逻辑。



到目前为止（gin v1.7.4) 暂 **内部** 无解决方法， 只能通过添加 **nginx 代理** 删除 `/` 或者， 祈祷客户端不要请求错误地址。



> https://github.com/gin-gonic/gin/issues/568
>
> https://github.com/gin-gonic/gin/issues/1985
>
> https://github.com/gin-gonic/gin/issues/1985





## 常规 301 



```go
dep := base.Group("/deployments")
{

  // 主动 301 
  dep.GET("/", func(c *gin.Context) {
    // 删除尾部的 / ， 在重组地址
    _url := strings.TrimRight(c.Request.URL.Path, "/") + "?" + c.Request.URL.RawQuery
    c.Redirect(301, _url)
  })

  // 针对 所有 deployment 操作
  dep.GET("", handlerListDeployments)
}
```



从 **network 瀑布** 中可以看到， 客户端向服务端发送了 **2次** 请求。

![image-20210928110403752](/assets/img/post/2021/2021-09-27-axios-301-redirect-cors-error/image-20210928110403752.png)

**第一次** 请求拿到了 301 的相关信息

![image-20210928110415307](/assets/img/post/2021/2021-09-27-axios-301-redirect-cors-error/image-20210928110415307.png)

**第二次** 请求指向了新地址

![image-20210928110422999](/assets/img/post/2021/2021-09-27-axios-301-redirect-cors-error/image-20210928110422999.png)



从服务端的日志也可以看到， 客户端确实发送了 **2次** 请求

![image-20210928110737272](/assets/img/post/2021/2021-09-27-axios-301-redirect-cors-error/image-20210928110737272.png)



