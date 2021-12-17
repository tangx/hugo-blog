---
date: "2021-08-26T00:00:00Z"
description: golang 下划线完成对象的接口类型检查
keywords: golang
tags:
- golang
title: golang 下划线完成对象的接口类型检查
---

# golang 下划线完成对象的接口类型检查



在 [Gin 源码中](https://github.com/gin-gonic/gin/blob/4e7584175d7f2b4245249e769110fd1df0d779db/routergroup.go#L53)  有一行代码如下

```go
var _ IRouter = &RouterGroup{}
```

乍一看， 是一个 **赋值** 操作， 但是前面又使用了 **空白描述符(下划线)** 。 这是什么意思呢？

**答案是： 接口类型检查**



在 **《Effective GO》** [Interface Check](https://golang.org/doc/effective_go#blank_implements) 中的描述有相关描述。 全文如下。 



> One place this situation arises is when it is necessary to guarantee within the package implementing the type that it actually satisfies the interface. If a type-for example, `json.RawMessage`  - needs a custom JSON representation, it should implement `json.Marshaler`, but there are no static conversions that would cause the compiler to verify this automatically. If the type inadvertently fails to satisfy the interface, the JSON encoder will still work, but will not use the custom implementation. To guarantee that the implementation is correct, a global declaration using the blank identifier can be used in the package:

```go
var _ json.Marshaler = (*RawMessage)(nil)
```

>  In this declaration, the assignment involving a conversion of a `*RawMessage` to a `Marshaler` requires that `*RawMessage` implements `Marshaler`, and that property will be checked at compile time. Should the `json.Marshaler` interface change, this package will no longer compile and we will be on notice that it needs to be updated.

> The appearance of the blank identifier in this construct indicates that the declaration exists only for the type checking, not to create a variable. Don't do this for every type that satisfies an interface, though. By convention, such declarations are only used when there are no static conversions already present in the code, which is a rare event.



简单总结一下

1. 假设已有一个 **接口** `json.Marshaler`， 我们自己编码创建了一个 `RawMessage` 对象。

2. 如果 `RawMessage` 对象能满足 `json.Marshaler` 接口一切皆大欢喜， 但是如果不满足， 那么在运行中就可能出现严重异常。 然而， 在 **编码阶段**  编译器并不能 **自动发现**  用户对象是否满足接口。

3. 因此， 使用了 `var TheInterface = *CustomStruct{}`  **（不满足不能赋值）** 这种方式进行编码阶段的验证。  但是 golang 特性， 声明了的变量必须要使用。

4. 为了解决 **声明但不使用** 的情况， 引入了 **空白描述符 `_` 下划线** 解决这个问题。 有了空白描述后， 行为就从**赋值** 变更为 **检查而不创建变量** 。 

   `var _ TheInterface = *CustomStruct{}` 

5. 最后官方提醒， 这种 **奇怪** 行为不要乱用， **只用在** 那些不能 **静态检查** 的对象上面。

