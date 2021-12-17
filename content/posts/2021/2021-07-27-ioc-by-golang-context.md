---
date: "2021-07-27T00:00:00Z"
description: 在 golang 中， context 天然具有传播性。 因此使用 context 作为 IoC 容器是一个不错的选择。
keywords: golang, ioc, 控制反转
tags:
- golang
title: golang 使用 Context 实现 IoC 容器
---

# golang 使用 Context 实现 IoC 容器

参考文章 [控制反转（IoC）与依赖注入（DI）](https://www.jianshu.com/p/07af9dbbbc4b) 指出了依赖注入可以降低程序的耦合性。 能更好的拆分功能与基础设施。

![ioc container](/assets/img/post/2021/07/27/golang-context-ioc/ioc.jpg)


那么在 golang 中又怎么实现呢？

![golang-context-ioc.png](/assets/img/post/2021/07/27/golang-context-ioc/golang-context-ioc.png)

[代码地址 golang-context-ioc.go](/assets/img/post/2021/07/27/golang-context-ioc/golang-context-ioc.go)

1. 实现了一个 `MysqlDriver` 实现我们所有的数据存取操作。 并在全局域中实例化了一个对象 `my`。
2. 在 `main.go` 中创建了一个 `ctx := context.Background()`
3. 使用使用 `ctx` 作为 IoC 容器， 使用 `db` 作为 **key** 将 `my` 对象存放进去。
4. 在 `save(ctx)` 正常传递 ctx
5. 在 `save()` 函数内部， 使用 context 特性， 将 `db` 对应的对象取出来， 并进行 `db.(*MysqlDriver)` 断言，还原成 `my` 实例对象。
6. 使用 `my` 的方法， 例如 `my.Save()` 进行**数据存储**操作。

至此， context 实现了 IoC 容器的功能。
