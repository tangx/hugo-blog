---
date: "2021-06-22T00:00:00Z"
description: 了解 golang block 的覆盖范围
keywords: golang, 闭包
tags:
- golang
title: Golang Block 到底是什么？ 怎么就能解决闭包变量冲突了？
---

# Golang Block 到底是什么？ 怎么就能解决闭包变量冲突了？

什么？ 你告诉我 `i:=i` 不仅合法，而且还常用。甚至能解决并发编程中的变量冲突？

以下这段代码出自 `golang 官方` 的 `Effective GO` 并发编程章节。 为了解决 goroute 中变量 `req` 冲突， 使用了语句 `req := req`

> https://golang.org/doc/effective_go#concurrency

```go
func Serve(queue chan *Request) {
    for req := range queue {
        req := req // Create new instance of req for the goroutine.
        sem <- 1
        go func() {
            process(req)
            <-sem
        }()
    }
}
```

`req := req` 这种写法是不是感到很奇怪？ 看看 `Effective GO` 怎么说？

> but it's legal and idiomatic in Go to do this. You get a fresh version of the variable with the same name, deliberately shadowing the loop variable locally but unique to each goroutine.
>
> 不仅合法，而且还**常用**。  这么做是为了在循环体内部将得到一个同名变量， 以隐藏 **循环变量 req**， 从而每个 goroute 得到一个唯一 `req`。

直接这么看，还是有点拗口。 不过不重要， 在了解了 golang 的 **区块(block)** 定义范围之后， 就迎刃而解了。


## Blocks

> https://golang.org/ref/spec#Blocks

> A `block` is a possibly empty sequence of declarations and statements within matching brace brackets.


### 什么是 `Blocks`？ 

1. 用 **大括号** `{}` 包围的一个代码块。
2. 这个代码块内容也可以为空， 也可以是有内容。

```go
Block = "{" StatementList "}" .
StatementList = { Statement ";" } .
```

### Block 的范围在哪里？

除了我们上面说的 **以大括号`{}`包围的代码块** 这种 **显式** block 之外， go 语言还存在几种 **隐式** 的 block。

#### 1. `universe` 全局

> The universe block encompasses all Go source text.

`universe` 这个词不怎听说， 但是换成 **全局** 这个概念还是很好理解的。

#### 2. `package` 包

> Each package has a package block containing all Go source text for that package.

`package` 就是最常见的 `package` 包。 作用域也很明确， 使用类似 `package.Variable` 。

#### 3. `file` 文件

> Each file has a file block containing all Go source text in that file.

文件级别的隐式 `block`。 这个其实还是有点意思的。 

目前发现现象， 

1. **test文件** `filename_test.go` 中的 **变量/函数** ， 在 **主程序文件** `filename.go` 中是无法引用的。
2. 在 **主程序文件** 中的 ` **变量/函数** 在 **test文件** 中是无法引用的。
3. **test文件** 之间的是可以互相引用的。
4. **主程序** 之间的是可以互相引用的。

因此推测（无实锤）， 1. 存在 `file block`。 2. 并且有高低等级之分。

其实很好理解， `_test` 是用于测试的， 肯定不能干扰主干程序的的环境。

![](/assets/img/post/2021/06/golang-block/file-block.png)

**注意**: 图片中是两个文件， 上 `main_test.go` 下 `main.go`。 并且 *编译器* 很明显的提示了， 在 `main.go` 中找不到变量 `VarInTest`。

#### 4. `for`, `if`, `switch` 的隐式 block

> Each "if", "for", and "switch" statement is considered to be in its own implicit block.

1. `for`, `if`, `switch` 本身是一个 **隐式的 block**
2. 其语法中的 **大括号`{}`** 所包围的区域是一个 **显式的 Block**。

![](/assets/img/post/2021/06/golang-block/for-block-1.png)

1. for block (19-26 行) 本身就是一个 **隐式的 block** 。
2. for **大括号`{}`** 部分(20-25行) 的 是一个 **显式的 block** ， 作为 `for block` 的 **子 block `(statement block)`** 存在

因此， 在 22 行 `i:=i` 是合法的， **在 `statement block` 中产生了 `同名变量覆盖`**。

![](/assets/img/post/2021/06/golang-block/for-block-2.png)

也就是因为 {} 是 for 子block 的原因， for 的 post 可以修改变量 i， 在 statement 中也可以修改变量 i

1. 因此， 在 35 行被注释的时候， for block 的变量 i 被继承，并在 if block 中被修改， 所以结果是 `loop: 0,1,2,9`
2. 当 35 行存在的时候， `for block` 中的变量 `i` 被 `statement block` 继承， 并进行 **同名覆盖** , 之后以 `_i` 说明。 所以， 在 `if block` 继承了 `statement block` 中的 `_i` 并修改。 此时， `for block` 的 `i` 并未受到影响。 因此结果是: `loop: 0-9`

#### 5. `switch / select` 中`clause` 的 隐式 block

> Each clause in a "switch" or "select" statement acts as an implicit block.

1. `switch / select` 更为特殊一点， 除了包含 **大括号** 以外， 还包含条件语句逻辑。 并且 **条件语法代码块** 也是一个 **隐式的 block**。 
2. 这个 **隐式 block** 包含了 `case / default:` 本身之外， 还包含了 **下一层的缩进 Statement 区域** 。

![](/assets/img/post/2021/06/golang-block/switch-clause.png)

1. 注释 20 行， 可以很清楚的看到报错， `func block` 中的 `i` 在申明后并未使用。 此说明了 switch 本身是一个 隐式 block。
2. `switch clause 分支` 整体 **(case 10-14 行)/(default 15-17)** 是一个 block。 为什么？ 11 行的 `{` 不能放到 10 行 最后面，



