---
date: "2021-06-21T00:00:00Z"
description: null
keywords: golang, defer
tags:
- golang
title: 正确理解 golang 函数变量的作用域, 管你 defer 不 defer
---

# 正确理解 golang 函数变量的作用域, 管你 defer 不 defer

你以为面试中的 defer 是在考 defer 吗？ 并不是，其实是在考 **函数变量的作用域**

以下这是 go语言爱好者 97 期的一道题目。
要求很简单， 代码执行 i, j 的值分别是什么。

```go
func Test_Demo(t *testing.T) {
	i := 10
	j := hello(&i)
	fmt.Println(i, j)
}

func hello(i *int) int {
	defer func() {
		*i = 19
	}()
	return *i
}
```

这道题虽然代码少， 但是考点还是蛮多的

1. 核心: **函数变量作用域** 
2. defer 执行时间
3. 闭包
4. 指针

## 知识点

这里面所有的内容都可以在 [Effective Go 中解决](https://golang.org/doc/effective_go)

### 贪婪算法

什么是贪婪算法， **就是找到局部最优解， 合并后就是全局最优解**。

怎么找局部最优解， 就是要 **对事情进行抽象，掌握事情的本质** 。

### defer 延迟执行

**defer** 就是语句进行压栈(`FILO`)处理， 延迟到 **在函数 `return` 之前执行** 执行。
本身没什么难点。 其设计目的也很明确就是为了 **解决资源释放** 的问题。

1. `open` 和 `close` 写在一起， 语意更直观。
2. 解决因为错误退出，导致而 **无法或忘记** 释放资源

> Effective Go 中对 `defer` 的概述。
>> It's an unusual but effective way to deal with situations such as resources that must be released regardless of which path a function takes to return. 
>>
>> 这是一种不寻常但有效的方法来处理诸如必须释放资源的情况，而不管函数采用哪条路径返回。

因此 defer 有什么好考的， 而且实际场景代码也不会那样写（违反了**可读性**的这一基本之准则）。

所以通常面试中有 defer 的问题都不是在考 defer ， 只不过是披上了 defer 的狼皮。 

### 函数及返回值

其实 go 中关于函数返回花样还是挺多的。 

1. 命名的/匿名的 返回值 `func NamedResult(i, j int) (x int)`
2. 带参数不带参数的 return `return`

感觉和 golang 本身的代码可读性的的理念有一点冲突。 就像为什么不支持三元运算符一样。
其实这样本身也没有什么， 就是一两个 **死记硬背** 的知识点而已。

但是遇到了 `defer`, `闭包`, `指针` 中对变量有操作， 那么问题可能就大了。

如果对 **函数变量的作用域** 理解不清楚的话， 就容易掉坑。


```go
package main

// 命名结果
func NamedResult(i, j int) (x int) {
	x = i + j
	// 默认返回
	return
}

// 匿名结果
func UnnamedResult(i, j int) int {
	// 指定返回
	return i + j
}
```

我们开启汇编， 查看一下函数过程

```bash
go tool compile -N -l -S  main.go
```

![name-unnamed-result.png](/assets/img/post/2021/06/golang-named-unnamed-result/named-unamed-result.png    )


从汇编结果可以看到: 

1. 虽然我们在 `UnnamedResult` 代码中没有显式的提供返回值的变量名， 但是 golang 自动为我们生成了一个叫 `~r2` 变量名， 其 **等价于 `NamedResult` 函数中的变量`x`**
2. 汇编中 `RET`后**没有**带任何参数
  + 所有与结果有关的操作都标记了 `(SP)` , ex: `MOVQ    AX, "".~r2+24(SP)`

既然如此， 我们就将所有函数的写法全部统一， 不再区分 **命名的、 匿名的** ， **默认的， 指定的**

1. **命名返回值**
2. **return 指定结果**

```go
func ReformResult(i, j int) (r2 int) {
	r2 = i + j
	return r2
}
```

这样看起来， 整个函数就清晰的多了。

## 实战练习一下

![little-rabbit](/assets/img/post/2021/06/golang-named-unnamed-result/little-rabbit.jpeg)

根据之前所说， 我们这里来对函数做一下整形手术。

```go
func Test_reformDemo(t *testing.T) {
	i := 10
	j := reformHello(&i)
	fmt.Println(i, j) // 19 10
}

// hello 原函数
func hello(i *int) int {
	defer func() {
		*i = 19
	}()
	return *i
}

// reformHello 整形函数
// reform 1. 匿名变命名
func reformHello(i *int) (_x int) {
	// reform 2. return 拆分
	// reform 2.1 显式赋值
	_x = *i  // _x=10

	// reform 3. defer 在返回前执行 
	func() { *i = 19 }()  // *i=19

	// reform 2.2 显式返回
	return _x // _x=10
}
```
