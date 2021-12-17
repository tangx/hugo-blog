---
date: "2021-11-26T00:00:00Z"
description: 如何处理程序配置文件才能在程序启动时适配更多情况
featuredImagePreview: topic/golang.png
keywords: golang, config
tags:
- golang
title: 配置文件初始化思路一二三
typora-root-url: ../../
---

# 配置文件初始化思路要点一二三

配置文件字段如下

```go
type Config struct {
	Server    Server            `json:"server,omitempty" yaml:"server,omitempty"`
	Ingresses netv1.IngressSpec `json:"ingresses,omitempty" yaml:"ingresses,omitempty"`
}
```

完整配置如下

```yaml
server:
  port: 8080

ingresses:
  rules:
    - host: www.baidu.com
      http:
        paths:
        - backend:
            service:
              name: /search
              port:
                number: 80
          pathType: ImplementationSpecific
          # pathType: Exact
          # pathType: Prefix
```

## Config 文件

读取多个文件后合并最终结果。 可以将不同的功能配置放在不同的文件中， 在数据内容多的情况下更有利于操作。

除此之外， 还可以按照环境读取不同的配置文件( `config.master.yml` / `config.develop.yml` )， 这种方式在 CICD 中就可以体现出优势了。

例如， 之后在读取 k8s 信息渲染路由配置文件时， 可以只更改 `config.ing.yml` 文件。

```go
func (cfg *Config) ReadConfig() {
	for _, f := range []string{"config.default.yml", "config.yml", "config.server.yml", "config.ing.yml"} {
		err := cfg.readconfig(f)
		if err != nil {
			logrus.Warnf("read file %s failed: %v", f, err)
			continue
		}
	}
}

func (cfg *Config) readconfig(file string) error {
	b, err := os.ReadFile(file)
	if err != nil {
		logrus.Warnf("read config failed: %v", err)
		return err
	}

	return yaml.Unmarshal(b, cfg)
}
```

除了读取配置文件之外， **生成** 默认的配置文件也是非常重要的。 
为所设计的 **配置字段** 创建一个默认值， 在程序启动的时候生成默认配置， 如此任何配置字段的都会在程序启动时体现出来， 而不必再花时间进行文档整理。

```go

func NewConfig() *Config {
	return &Config{
		Server: Server{
			Port: 8080,
		},
	}
}

func (cfg *Config) Initial() *Config {

	b, _ := yaml.Marshal(cfg)
	f, _ := os.OpenFile("config.default.yml", os.O_CREATE|os.O_RDWR|os.O_TRUNC, 0644)
	defer f.Close()

	f.Write(b)
	return cfg
}
```


## Config 字段

config 字段在设计的时候直接使用了 k8s 的 Ingress 字段。 方便之后直接使用，不再做转换。

```go
type Config struct {
	Server    Server            `json:"server,omitempty" yaml:"server,omitempty"`
	Ingresses netv1.IngressSpec `json:"ingresses,omitempty" yaml:"ingresses,omitempty"`
}
```
