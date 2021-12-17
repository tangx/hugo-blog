---
date: "2021-09-18T00:00:00Z"
description: golang 使用反射绑定 cobra flag 参数
img: post/2021/2021-09-18-golang-cobra-flag-binder/20200309153711.png
keywords: golang, reflect
tags:
- golang
- reflect
title: golang 使用反射绑定 cobra flag 参数
typora-root-url: ../../
---



# golang 使用反射绑定 cobra flag 参数



`cobra`  https://github.com/spf13/cobra 是 golang 中一个非常好用的 **命令** 开发库。 

但是绑定 `flag` 参数的时候略微有点繁琐， 不但有多少个参数就需要写多少行绑定代码， 而且参数定义和描述也是分开的， 非常的不直观。

```go

func init() {
    rootCmd.Flags().StringVarP(&stu.Name, "name", "", "zhangsanfeng", "student name")
    rootCmd.Flags().Int64VarP(&stu.Age, "age", "a", 18, "student age")
    // ...
}
```

想着吧， 反正都要了解 `golang reflect 反射`, 不如就用 **反射** 实现一个绑定支持。
老实说， 反射一开始用起来， 还真让人头疼， 各种转换绕来绕去。
所有操作步骤都在代码中有了简单明了的注释  https://github.com/go-jarvis/cobrautils/blob/master/flagx.go

完成后，只需要一行代码就可以完成所有绑定。 还真是挺香的。

```go
cobrautils.BindFlags(rootCmd, &stu)
```



## 安装

```bash
go get -u github.com/go-jarvis/cobrautils
```

## 使用方式

> Attention: 由于 cobra 中对数据的处理方法很细致， 因此数据目前支持 `int, int64, uint, uint64`。 

flag 与 `cobra` 定义一致

```go
func (f *FlagSet) Uint64VarP(p *uint64, name, shorthand string, value uint64, usage string) {
	f.VarP(newUint64Value(value, p), name, shorthand, usage)
}
```

### flag 设置

```go
type student struct {
    Name    string `flag:"name" usage:"student name" persistent:"true"`
    Age     int64  `flag:"age" usage:"student age" shorthand:"a"`
}
```

1. `flag:"config"` : flag 的名字, `--config`， 嵌套 struct 之间使用 `.` 连接, `--config.password`
2. `shorthand:"c"` : 参数简写 `-c`, 简写没有潜逃
3. `usage:"comment balalal"`: 参数说明
4. `persistent` : 全局

### 默认值设置

由于所有参数的值最终都需要一个接收者， 保存之后才能够背调用。
因此， 默认值的设置就放在 `struct` 实例化一个对象中。

```go
stu := student{
    Name:   "zhangsanfeng",
    Age:    20100
}
```

### 键值绑定

```go
// 绑定
cobrautils.BindFlags(rootCmd, &stu)
_ = rootCmd.Execute()

// 打印结果
fmt.Printf("%+v", stu)
```
## 完整 Demo

```go
package main

import (
    "fmt"

    "github.com/go-jarvis/cobrautils"
    "github.com/spf13/cobra"
)

type student struct {
    Name    string `flag:"name" usage:"student name" persistent:"true"`
    Age     int64  `flag:"age" usage:"student age" shorthand:"a"`
}

var rootCmd = &cobra.Command{
    Use: "root",
    Run: func(cmd *cobra.Command, args []string) {
        _ = cmd.Help()
    },
}

func main() {
    stu := student{
        Name:   "zhangsanfeng",
        Age:    20100
    }

    cobrautils.BindFlags(rootCmd, &stu)
    _ = rootCmd.Execute()

    fmt.Printf("%+v", stu)
}
```

执行结果 

```bash
go run . --name wenzhaolun
Usage:
    root [flags]
Flags:
    -a, --age int            student age (default 20100)
    -h, --help               help for root
        --name string        student name (default "zhangsanfeng")

{Name:wenzhaolun Age:20100}
```

`Demo`: [example](examples/main.go)

