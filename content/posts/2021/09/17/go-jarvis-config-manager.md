---
date: "2021-09-17T00:00:00Z"
description: 不仅支持根据配置生成配置文件， 更支持从配置文件和环境变量中反向给配置赋值
img: /post/2021/2021-09-17-go-jarvis-config-manager/82073077.png
keywords: golang
tags:
- golang
title: go-jarvis 容器化 go 应用开发配置管理利器
typora-root-url: ../../
---

# `go-jarvis/jarivs`

![img](/assets/img/post/2021/2021-09-17-go-jarvis-config-manager/82073077.png)

为了方便 golang 容器化开发的时候管理配置。

## 核心功能

1. 根据 `config` 结构体生成 `yaml` 配置文件
2. 程序启动时， 从 `yaml` 配置文件和 **环境变量** 中对 `config` 赋值

### 执行逻辑

1. 根据配置 `config{}` 生成对应的 `default.yml` 配置文件。 
2. 读取依次配置文件 `default.yml, config.yml` + `分支配置文件.yml` + `环境变量`
    + 根据 GitlabCI, 分支配置文件 `config.xxxx.yml`
    + 如没有 CI, 读取本地文件: `local.yml`

### 使用需求

1. config 对象中的结构体中， 使用 `env:""` tag 才能的字段才会被解析到 **default.yml** 中。 也只有这些字段才能通过 **配置文件** 或 **环境变量** 进行初始化赋值。

2. config 中的对象需要有  `SetDefaults()` 和 `Init()` 方法。
    + `SetDefaults` 方法用于结构体设置默认值
    + `Init` 方法用于根据默认值初始化

## demo 案例

初始化代码如下

```go
package main

import (
	"fmt"

	"github.com/gin-gonic/gin"
	"github.com/go-jarvis/jarvis"
)

type Server struct {
	Listen string `env:"addr"`
	Port   int    `env:"port"`

	engine *gin.Engine
}

func (s *Server) SetDefaults() {
	if s.Port == 0 {
		s.Port = 80
	}
}

func (s *Server) Init() {
	s.SetDefaults()

	if s.engine == nil {
		s.engine = gin.Default()
	}
}

func (s Server) Run() error {
	addr := fmt.Sprintf("%s:%d", s.Listen, s.Port)

	return s.engine.Run(addr)
}

func main() {
	server := &Server{}

	app := jarvis.App{
		Name: "Demo",
	}

	config := &struct {
		Server *Server
	}{
		Server: server,
	}
	// app.Save(config)

	app.Conf(config)
	// fmt.Println(config.Server.Port)

	server.Run()

}

```

### 生成的 yaml 配置文件

生成配置文件如下

```yaml
Demo__Server_addr: ""
Demo__Server_port: 80
```

在启动过程中， 如果环境变量中有同名变量, (例如 `Demo__Server_port`), 该变量值将被读取， 并复制给对应的字段。

