---
date: "2021-08-30T00:00:00Z"
description: 一道 golang 切片面试题
keywords: golang, slice
tags:
- golang
title: 一道 golang 切片面试题
---

# 一道 golang 切片面试题



为什么 `sl[:5]` 会返回底层数组的数据呢？ 



```go
package main

import "fmt"

func main() {
	sl := make([]int, 0, 10)
	appendFn := func(s []int) {
		// 值传递， s 并不是 sl。
		// 但数组是引用类型， 所以可以修改底层数组
		fmt.Println("s ptr(old):", s) // []
		s = append(s, 10, 20, 30)
		fmt.Println("s ptr(new):", s) // [10,20,30]

	}

	fmt.Println(sl) // []
	appendFn(sl)
	fmt.Println(sl) // []

	// 这里有点坑， 并不是取的 sl ，而是底层数组新创建的 slice
	fmt.Println(sl[:5]) // [10,20,30,0,0]
	// 等价于
	sl1 := sl[:5]
	fmt.Println(sl1)  // [10,20,30,0,0]

}

```

