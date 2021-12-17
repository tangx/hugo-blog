---
date: "2021-09-09T00:00:00Z"
description: 使用 ginbinder GET 请求也能传递 body 数据了
keywords: ginbinder, http
tags:
- golang
title: GET 请求也能传递 JSON Body
typora-root-url: ../../
---



#  GET 请求也能传递  Body 数据



通常而言， GET 请求很少传递 Body 数据， 大多情况下都是放在 **url** 中， 例如

```bash
http://example.com/api?key1=value1&key2=value2
```

但是这样做， 

1. 可能由于 **传递数据过多** 导致 URL 过程而被拦截。 
2. 运营商会缓存 URL 地址以达到加速的效果， 而有些参数又不想被缓存。
3. 等等

虽然， 可以使用 **POST** 请求代替 **GET** 请求， 在 **Body** 中传递数据， 但是这样做可能会破坏 **RESTful** 风格的 API 格式。



在标准协议中， **GET** 请求是可以携带 Body 数据的， 这些数据是否被处理， 全看 **接收端(后端)** 的行为。大多数情况下， 大家都选择放弃。 

例如 而 `gin-gonic/gin` 框架在处理 **GET** 请求的时候， 就选择忽略了 **Body** 数据。  

gin 在选择默认解释器的时候， 发现如果是 **GET** 请求， 无论 `Content-Type` 是什么， 都是使用 **表单 Form** 解释器。

以下代码基于当前最新的 **gin@v1.7.4**

[gin - binding/binding.go#L90](https://github.com/gin-gonic/gin/blob/v1.7.4/binding/binding.go#L90)

```go
var (
	JSON          = jsonBinding{}
	XML           = xmlBinding{}
	Form          = formBinding{}
	Query         = queryBinding{}
	FormPost      = formPostBinding{}
	FormMultipart = formMultipartBinding{}
	ProtoBuf      = protobufBinding{}
	MsgPack       = msgpackBinding{}
	YAML          = yamlBinding{}
	Uri           = uriBinding{}
	Header        = headerBinding{}
)


// Default returns the appropriate Binding instance based on the HTTP method
// and the content type.
func Default(method, contentType string) Binding {
  // 如果是是 GET 请求， 直接使用 Form 表单方式处理数据
	if method == http.MethodGet {
		return Form
	}
	switch contentType {
	case MIMEJSON:
		return JSON
	case MIMEXML, MIMEXML2:
		return XML
  // ...
  }
}
```



[gin - binding/form.go#L21](https://github.com/gin-gonic/gin/blob/v1.7.4/binding/form.go#L21)

```go
func (formPostBinding) Bind(req *http.Request, obj interface{}) error {
  // 获取表单数据的时候， 使用 net/http 库的 req.ParseForm() 方法
	if err := req.ParseForm(); err != nil {
		return err
	}
	if err := mapForm(obj, req.PostForm); err != nil {
		return err
	}
	return validate(obj)
}
```



在  golang 中默认的 **`net/http`** 库， 在处理 **表单 form** 数据的时候， 特定的 **请求方法 GET/DELETE** 就选择忽略 body 数据

`golang(v1.16.5)` , 代码如下

> `net/http`  `request.go#L1251`

```go
// ParseForm populates r.Form and r.PostForm.
//
// For all requests, ParseForm parses the raw query from the URL and updates
// r.Form.
//
// For POST, PUT, and PATCH requests, it also reads the request body, parses it
// as a form and puts the results into both r.PostForm and r.Form. Request body
// parameters take precedence over URL query string values in r.Form.
//
// If the request Body's size has not already been limited by MaxBytesReader,
// the size is capped at 10MB.
//
// For other HTTP methods, or when the Content-Type is not
// application/x-www-form-urlencoded, the request Body is not read, and
// r.PostForm is initialized to a non-nil, empty value.
//
// ParseMultipartForm calls ParseForm automatically.
// ParseForm is idempotent.
func (r *Request) ParseForm() error {
	var err error
	if r.PostForm == nil {
    // 三个特定的请求方法， 选择读取 Body
		if r.Method == "POST" || r.Method == "PUT" || r.Method == "PATCH" {
			r.PostForm, err = parsePostForm(r)
		}
    // 其他方法， 选择从 URL 中获取。
		if r.PostForm == nil {
			r.PostForm = make(url.Values)
		}
	}
// ...
```



## ginbinder `v0.1.1`

`ginbinder` 是对 `gin` 绑定数据方法的一个扩展库。

 `v0.1.1` 的发布， 就实现了处理 `GET` 能获取 **Body** 数据的想法。

不过为了不违背 **gin** 和 **golang `net/http`** 原本的初衷， 在实现方式上有一个强制要求。 即对 `body` 结构体必须使用 `mime` tag 指定解释器。

```go
type Params struct {
	Name          string `uri:"name"`
	Age           int    `query:"age,default=18"`
	Money         int32  `query:"money" binding:"required"`
	Authorization string `cookie:"Authorization"`
	UserAgent     string `header:"User-Agent"`
	Data          struct {
		Replicas *int32 `json:"replicas"`
	} `body:"" mime:"json"`  // 通过 mime 强制指定 json 解释器
}
```

除了 **json** 解释器之外， `mime` 还支持 `yaml`, `xml` 两种解释器。

```go

// MimeBinding returns the appropriate Binding instance based on mime value in body tag
func MimeBinding(mime string) Binding {
	switch mime {
	case "json":
		return JSON
	case "xml":
		return XML
	case "yaml", "yml":
		return YAML
	}
	return nil
}
```



详细用法和demo， 可以查看 https://github.com/tangx/ginbinder 。

