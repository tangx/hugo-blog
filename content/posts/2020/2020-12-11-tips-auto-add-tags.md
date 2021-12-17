---
date: "2020-12-11T00:00:00Z"
description: golang 为 struct 自动添加 tags
keywords: goalng, vscode
tags:
- golang
- vscode
title: golang 为 struct 自动添加 tags
---

# golang 为 struct 自动添加 tags

vscode 中的 go `0.12.0` 版本新加入了一个 `auto add tags` 的功能。

`setting.json` 配置如下

```yaml
    "go.addTags": {
        "tags": "yaml,json",
        "options": "yaml=omitempty,yaml=options2,yaml=options3,json=omitempty",
        "promptForTags": false,
        "transform": "snakecase"
    },
```

在 `example.go` 中创建一个 `struct`

```go
type Person struct {
	Name   string
	Age    int
	Gender string
}
```

将光标移动到 struct 结构体中， 使用 `command + shift + p` 选择 `go: add tag for struct` 即可

`result`
```go
type Person struct {
	Name   string `yaml:"name,omitempty,options2,options3" json:"name,omitempty"`
	Age    int    `yaml:"age,omitempty,options2,options3" json:"age,omitempty"`
	Gender string `yaml:"gender,omitempty,options2,options3" json:"gender,omitempty"`
}
```