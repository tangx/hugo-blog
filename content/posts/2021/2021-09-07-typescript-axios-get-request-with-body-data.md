---
date: "2021-09-07T00:00:00Z"
description: axios get 请求携带 body 数据
keywords: typescript
tags:
- typescript
- axios
title: axios get 请求携带 body 数据
typora-root-url: ../../
---



# axios get 请求携带 json body 数据

在 **http** 标准协议中， **GET 请求** 本身是可以携带 **Body 数据** 。 

至于 **GET** 请求携带的数据能不能被获取， 还是要看接受端 **后端** 是否处理。

在 `gin-gonic/gin` 框架中， **GET** 请求默认就不会处理 body 中的数据， 只能通过 **query** 表单数据传递。

然而不同的浏览器对于 URL 长度的限制也不同，一般是 1024 个字符， 

	1. 有些时候需要携带的数据可能超过这个限制。 
 	2. 有些时候携带的数据不想被运营商缓存。

虽然可以使用 **POST** 的方式实现数据请求， 但是根据 **RESTful**  的 API 风格就被破坏了。

##  使用 golang 创建一个后端服务器



1. 使用 `gin` 搭建一个 web 服务器
2. 使用 `ginbinder` 绑定 get 请求中的所有数据。 **
   + `ginbinder` 是一个 `gin` 扩展， 可以一次性处理 `http request` 中携带的所有参数。 可以访问 https://github.com/tangx/ginbinder 了解更详细的用法。
3. 这里使用了 `mime:"json"`  强制使用  **json** 解析器解析 **body** 数据， 不再依赖客户端传递的 `content-type`

```go
package main

import (
	"github.com/gin-gonic/gin"
	"github.com/tangx/ginbinder"
)

type Params struct {
	ID    string `uri:"id"`
	Money int    `query:"money"`
	Data  struct {
		Name string `json:"name"`
		Age  int    `json:"age"`
	} `body:"" mime:"json"`  // get 请求支持 body 传递数据， 并使用 json 解析
}

func main() {
	r := gin.Default()
	r.GET("/get/:id", handler) 
	r.Run(":8088")
}

func handler(c *gin.Context) {
	p := Params{}

	// ginbinder 是 gin 的一个扩展库
	// 可以一次性绑定 http request 携带的所有变量
	err := ginbinder.ShouldBindRequest(c, &p)
	if err != nil {
		panic(err)
	}

  // 返回参数对象
	c.JSON(200, p)
}

```



## 使用 axios 发送 GET 请求

`axios` 可以说是前端进行 http 请求必须使用的网络库了。 因此， 这里测试一下 `axios` 是否能够正常携带 **JSON body 数据**

1. 使用 `yarn add axios` 安装 `axios` 客户端
2. `package.json` 中添加 `"type": "module",` 使用模块组件
3. 创建 `data`  数据对象， 并使用 `JSON.stringify` 进行格式化
4. 使用 `axios` 发送 `get` 请求

```typescript
import axios from 'axios'

async function get() {

    // 定义 data 数据对象
    const data = {
        name: "wangwu",
        age: 30
    }
    // 格式化成 json 字符串
    const _data = JSON.stringify(data)

    // 使用 axios 发送请求
    let resp = await axios({
        method: "get",
        url: "http://127.0.0.1:8088/get/id12312312?money=300",
        data: _data,
    })

    // 输出结果， 成功获取
    // { ID: 'id12312312', Money: 300, Data: { name: 'wangwu', age: 30 } }
    console.log(resp.data); 

}

// node main.js
get() 
```

