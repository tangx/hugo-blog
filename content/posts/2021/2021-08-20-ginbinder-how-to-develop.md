---
date: "2021-08-20T00:00:00Z"
description: 在开发 ginbinder 过程中的一些知识点
keywords: go, reflect
tags:
- golang
title: ginbinder 的书写过程-一起来看gin源码吧
---

# ginbind 的实现过程-一起来看gin源码吧



是的，没错。 

如果你用过 `gin` 那么你一定知道，`gin` 中绑定参数的方式很零散。 `c *gon.Context` 给你提供了很多中方法， 例如`BindHeader`, `BindURI` 等等， 但是如果想要绑定 reqeust 中不同地方的参数， 那对不起咯，并没有。

另外， gin 中的 `Bind` 接口， 默认是包含了 **参数验证 validate** 功能的， 因此如果你想直接使用默认的绑定方法， 就会出现很多验证不通过的情况。这里有一公升的泪水。

鉴于以上两点， 不得不自己改造 gin， 然后提 PR [feat: add methods `c.BindCookie(obj)` from cookie and `c.BindRequest(obj)` from http request #2812](https://github.com/gin-gonic/gin/pull/2812) 。 

然而， 我自己也觉得估计被合并的机会太小了， 对原来的 `binder` 的改造和破坏有点大。



## 那么，开始吧



### `c.Bind`



gin 中有一个绑定方法 `c.Bind(obj)` 是一个动态绑定器， 使用它不需要传入什么方法， 就可以绑定 `req.Body`。 

源码如下，

> https://github.com/gin-gonic/gin/blob/v1.7.4/context.go#L661

```go
// ShouldBind checks the Content-Type to select a binding engine automatically,
// Depending the "Content-Type" header different bindings are used:
//     "application/json" --> JSON binding
//     "application/xml"  --> XML binding
// otherwise --> returns an error
// It parses the request's body as JSON if Content-Type == "application/json" using JSON or XML as a JSON input.
// It decodes the json payload into the struct specified as a pointer.
// Like c.Bind() but this method does not set the response status code to 400 and abort if the json is not valid.
func (c *Context) ShouldBind(obj interface{}) error {
	b := binding.Default(c.Request.Method, c.ContentType())
	return c.ShouldBindWith(obj, b)
}
```



调用了 `binding.Default()` 方法， 通过 `req.Method` 和 `content-type` 选择了一个 **绑定器** 。 使用 `c.ShouldBindWith(obj,b)` 执行数据绑定。

> 这里就不展开了， 点进去之后是一个 switch 表达式， 返回一个 绑定器
>
> https://github.com/gin-gonic/gin/blob/v1.7.4/binding/binding.go#L90



### `c.ShouldBindWith`

1. 跟随 `c.ShouldBindWith` 来到 [context.go#L703](https://github.com/gin-gonic/gin/blob/v1.7.4/context.go#L700) 行， 这里直接调用 `c.Bind()` 并返回了结果。

2. 跟随 `c.Bind()` 来到 [binding.go#L30](https://github.com/gin-gonic/gin/blob/v1.7.4/binding/binding.go#L90) 行， 可以看到，这里是一个接口。

> https://github.com/gin-gonic/gin/blob/v1.7.4/context.go#L700
>
> https://github.com/gin-gonic/gin/blob/v1.7.4/binding/binding.go#L30



因此， 只要满足了 `Binding` 接口的的绑定器， 就能使用 `c.ShouldBindWith` 

```go
// Binding describes the interface which needs to be implemented for binding the
// data present in the request such as JSON request body, query parameters or
// the form POST.
type Binding interface {
	Name() string
	Bind(*http.Request, interface{}) error
}

// BindingBody adds BindBody method to Binding. BindBody is similar with Bind,
// but it reads the body from supplied bytes instead of req.Body.
type BindingBody interface {
	Binding
	BindBody([]byte, interface{}) error
}
```



### 绑定器 binders

重新跟随 `binding.Defualt` 来到 [binding.go#L74](https://github.com/gin-gonic/gin/blob/v1.7.4/binding/binding.go#L74) 行， 可以看到这里内置了很多绑定器， 有些都是在 README.md 上没有介绍的，是否有介绍取决于提PR的人是否更新了 README。

```go
// These implement the Binding interface and can be used to bind the data
// present in the request to struct instances.
var (
	JSON          = jsonBinding{}
	XML           = xmlBinding{}
	// ... 省略
	Uri           = uriBinding{}
	Header        = headerBinding{}
)
```

> https://github.com/gin-gonic/gin/blob/v1.7.4/binding/binding.go#L74



随意点一个点一个进去， 可以看到 binders 是如何实现**具体绑定数据操作的**

例如这里的 [uri.go](https://github.com/gin-gonic/gin/blob/v1.7.4/binding/uri.go)

> https://github.com/gin-gonic/gin/blob/v1.7.4/binding/uri.go

```go
func (uriBinding) BindUri(m map[string][]string, obj interface{}) error {
	if err := mapUri(obj, m); err != nil {
		return err
	}
	return validate(obj)
}
```



然后很遗憾的是， 所有 binders 都是返回前都进行了 `validate(obj)` ，这也就是我之前说的公升泪和汗水。 

如果参数带有 `validate` 相关的 `tag`， 无法在一个 Params 结构体中写入所有需要的参数。 然后通过多次调用相关的绑定方法完成所需参数的赋值。

```go
// 这里会出问题
type MyParams{
  Age int `form:"age" required:"...."`
  Name int `uri:"age" required:"...."`
}

var obj=&MyParams{}
err = c.BindQuery(obj) 
err = c.BindUri(obj)
```



那么操作阶段就很明显了， 

1. 自己创建一个 binder ， 实现所有的绑定逻辑。
2. 拆分一下原生的binder 的 `bind` 和 `validate` 逻辑， 还是自己创建一个 binder ，复用 `bind` 逻辑 返回前在执行才执行一次 `validate`



我这么懒， 肯定选第二种咯



## 改造开始



### gin 原生拆分接口



为了能够复用原生的绑定逻辑， 我把原来的 `Binding` 接口增加了一个方法 `BindOnly`。 

1.  新增加的 `BindOnly` 方法只对数据进行绑定，不做任何 `validate` 的操作。
2. `Bind` 对外保持保持一致，依旧 `validate` 之后返回数据，  因此对 `BindOnly` 的返回结果进行 `validate` 就行了。

并且对外暴露了两个方法， 使用 `BindOnly` 就可以解决**用户自由组合** 的问题。

```go
type Binding interface {
	Name() string
	Bind(*http.Request, interface{}) error // with validate
	BindOnly(*http.Request, interface{}) error // without validate
}
```



下面是 `queryBinding` 的对比， 其他类似。

**origin query binder**

```go
// origin
func (queryBinding) Bind(req *http.Request, obj interface{}) error {
	values := req.URL.Query()
	if err := mapForm(obj, values); err != nil {
		return err
	}
	return validate(obj)
}
```

 **new query binder**

```go
// new
func (b queryBinding) Bind(req *http.Request, obj interface{}) error {
  
  // 先 BindOnly
	if err := b.BindOnly(req, obj); err != nil {
		return err
	}

  // 数据验证
	return validate(obj)
}

func (queryBinding) BindOnly(req *http.Request, obj interface{}) error {
	values := req.URL.Query()
	if err := mapForm(obj, values); err != nil {
		return err
	}
	return nil
}
```



## ginbinder 设计



### 怎么锁定数据来源

先来看看一个 http request 请求是怎么样的

```http
POST http://127.0.0.1:9881/demo1/zhangsan?money=1000
Content-Type: application/json
Accept-Language: en-GB,en-US;q=0.8,en;q=0.6,zh-CN;q=0.4
Cookie: Authorization=auth123123;

{
    "replicas":5
}
```

1. URI 参数: `zhangsan`

2. Query参数:  `money=1000`

3. Header 参数: `content-type: application/json` ...

4. Cookie 参数: `Authorization=auth123123;`

5. Body 参数: `{"replicas":5}`



按照以下这样， 就设计出了了一个参数， 其结构与 Request 请求体类似



```go
type Params struct {
  Name string `uri:"name"`
  Money int `query:"money"`
  ContentType string `header:"Content-Type"`
  Authorization string `cookie:"Authorization"`
  Data struct {
    Replicas int `json:"replicas"`
  } `body:""`
}
```



### 非 Body 数据处理



对于非 Body 数据， gin 原生已经为了提供了绑定方法， 之前我们已经改造出了 `BindOnly` 方法， 直接使用即可。所以这部分相对简单。

但是，在对 `Query` 的处理时， 遇到了一个些问题。 由于 gin 之前对 `Query` 的处理使用时 `form` tag。这个在 POST 提交 form 表达的的时候会产生变量名的冲突。 因此这里使用了 `query` tag 名。

正好， 在 `gin` 提供了方法 `mapFormByTag`， 可以方便的绑定的自定义的的 tag。

> https://github.com/gin-gonic/gin/blob/v1.7.4/binding/form_mapping.go#L31



### Body 数据处理

在处理这部分的时候， 需要考虑

1. 由于原生 `mapFormByTag` 是递归处理 `params` 的， 所以要如何屏蔽 **非body** 的影响。
2. 如何将 `params.Data` 和 `req.Body` 对应起来。

这部分处理， 用到了 `go 的 反射` ， 想办法通过反射，把 `body` tag 的结构体返回， 然后调用原生的 `BindBodyOnly` 方法即可。

> https://github.com/tangx/ginbinder/blob/v0.0.1/binding/request.go#L76-L101

反射找 tag 只能算是**基本操作** 

```go
		// find body struct
		if reflect.Indirect(vf).Kind() == reflect.Struct {
			// body must not has tag "query"
			if hasTag(vf, "query") || hasTag(vf, "header") ||
				hasTag(vf, "cookie") || hasTag(vf, "uri") {
				panic(ErrInvalidTagInRequestBody)
			}

			return vf.Addr().Interface()
		}
```

但是需要注意的是

1. `reflect.Indirect` 获取对象的真实类型， 在进行比较，否则 **`vf`** 是指针时，无法正确比对。
2. 在返回时 `return vf.Addr().Interface()` 需要首先通过 `vf.Addr()` 的 `vf` 的指针， 否则 `params.Data` 时结构体时，后续无法绑定数据。
3. 为了解决 body 中的 tag 污染， 就强制 tag 出现违禁词就 panic。



## 封装一下



有了自建的 `request binder` 之后， 就来简单的封装一下， 让调用更简单。

```go
func ShouldBindRequest(c *gin.Context, obj interface{}) error {
  // 为了获取 uri 的数据
	params := make(map[string][]string)
	for _, v := range c.Params {
		params[v.Key] = []string{v.Value}
	}

  // 使用自建的 request binder
	return binding.Request.Bind(obj, c.Request, params)
}
```

