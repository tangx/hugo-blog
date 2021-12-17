---
date: "2021-09-22T00:00:00Z"
description: slice[a:b:c] 是什么意思? golang slice 完整表达式
image: topic/golang.png
keywords: slice[a:b:c] 是什么意思? golang slice 完整表达式
tags:
- golang
- slice
title: 在 golang 中 slice[a :b :c] 是什么意思? golang slice 完整表达式
typora-root-url: ../../
---

# golang slice 表达式

> https://golang.org/ref/spec#Slice_expressions

通常，我们写的 golang slice 边界只有**两个数字**  `slice[1:3]` ， 这是一种简单写法。 而完整写法是 **三个数字** `slice[1:3:5]` 

## 简单表达式

**一个冒号， 两个参数**， 表示 slice 元素的 **起止区间**

```go
a[low:high]
```



```go

package main

import (
	"fmt"
)

func main() {
	a := [5]int{1, 2, 3, 4, 5}

	s := a[1:4] // [2,3,4]
	fmt.Println(s)

	s1 := a[2:] // 等价于 a[2 : len(a)
	s2 := a[:3] // 等价于 a[0 : 3]
	s3 := a[:]  // 等价于 a[0 : len(a)]

	fmt.Println(s1, s2, s3)
}

```

> https://play.golang.org/p/7l99ScJXmi4



## 完整表达式

**两个冒号， 三个数字**， 分别表示 slice 的 **起、止和最大值**

```go
a[low:high:max]
```

+ `high-low` 为长度
+ `max-low` 为容量

![image-20210922223956354](/assets/img/post/2021/2021-09-22-golang-slice-expressions/image-20210922223956354.png)

```go
package main

import (
	"fmt"
)

func main() {
	a := [...]int{1, 2, 3, 4, 5, 6, 7, 8}
	t := a[1:3:5]                  // [2 3]
	fmt.Println(t, len(t), cap(t)) // [2 3] 2 4

	// a[1:3] 可以认为是 a[1:3:n] 其中
	n := len(a)
	s1 := a[1:3]
	s2 := a[1:3:n]
	fmt.Println(s1, len(s1), cap(s1)) // [2 3] 2 7
	fmt.Println(s2, len(s2), cap(s2)) // [2 3] 2 7
}

```

> https://play.golang.org/p/F7e7sEVu6W8



