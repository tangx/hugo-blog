---
date: "2021-07-28T00:00:00Z"
description: gin context 实现 ioc 需要使用内置方法 Set 与 Get。 与 golang context 类似， 但又有所不同。
keywords: golang, gin
tags:
- golang
- gin
title: golang gin 使用 context 实现 ioc
---

#  golang gin 使用 context 实现 ioc 

gin 是一个流行的 golang webserver 的框架。 [https://github.com/gin-gonic/gin](https://github.com/gin-gonic/gin)

gin 中 `HandlerFunc` (`type HandlerFunc func(*Context)`) 的使用随处可见, ex. *Middleware* , *Handler* 中。

```go
router.GET("/user/:name", func(c *gin.Context) {
		name := c.Param("name")
		c.String(http.StatusOK, "Hello %s", name)
	})
```

因此，根据之前 golang context 实现 IoC 容器经验，  使用 `*gin.Context` 作为 IoC 容器再好不过了。


标准库 `context.Context` 是一个接口(interface)， `gin.Context` 是 gin 工程自己封装的的一个 struct， 并实现了该接口。 虽然如此， 在实现的的时候， 还是有一点差别。

1. **存入字段方式不同**
    + 在 context 标准库中， 调用的是 **包函数 `context.WithValue` 将 `key,val` 写入 `ctx` 中并生成一个新的 `Context`
    + 在 gin 中， 使用的是 `gin.Context` `Set` 方法， 原 `ctx` 增加新字段，保持。
2. **key** 的类型不同
    + 在 context 标准库中， key 类型是 `interface{}` ， 可以存储任意类型。
    + 在 gin 中， key 类型是 `string` ， 有所限制。

```go
// 标准库 函数
func WithValue(parent Context, key, val interface{}) Context

// gin.Context 方法
func (c *Context) Set(key string, value interface{}) 
```

3. **数据取出方式不同**
    + 在 context 标准库中， 使用 `context.Context.Value(key interface{}) interface{}` 方法。
    + 在 gin 中， 除了可以使用标准接口方法外， 还可以使用 `gin.Context.Get(key string) interface{}` 方法， 并且返回值多一个 `bool 类型的 exists` 参数返回， 可以判断 key 值是否存在， 排除 **零值** 的干扰。


```go
// 标准库
    db := ctx.Value("db"

// gin
	// db := c.Value("db") // 实现了 Context 接口， 可以。
	db, exists := c.Get("db")

	if !exists {
		return
	}
```

4. **使用方式不同**
    + 在使用标准库中， 需要将 `context ioc` 传入到每一个函数 或 方法中。
    + 在使用 gin 时， 需要使用 gin middleware 功能， 将 `gin context ioc` 传入。

```go
// 标准库
// 
func save(ctx context.Context) {
	// ...
}

// gin
func main() {
	r := gin.Default()
	r.Use(GinContextIoC) // 使用 middleware 的方式在 context 中注入与传递
    // ...
}
```


### 完整 demo

这是一个实现了 gin context ioc 容器的 demo

![demo](/assets/img/post/2021/07/28/gin-context-ioc/gin-context-ioc.png)



[golang demo 源代码](/assets/img/post/2021/07/28/gin-context-ioc/gin-context-ioc.go)