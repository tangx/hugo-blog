---
date: "2021-09-07T00:00:00Z"
description: 如果 golang map 值不能被修改，可以通过重新赋值进行修改。
keywords: golang
tags:
- golang
title: 如果 golang map 值不能修改怎么办？
typora-root-url: ../../
---

## 值对象与指针对象

假设有一个 **map 对象** `map[string]Person` ， 其中 `Person` 定义如下。 是一个 `struct`

```go
type Person struct {
	Age int
}
```

现在有一个需求， **map** 中的 **Person** 对象年龄为 0 ， 则将其默认值设置为 18。

**很显然**， 由于 `map[string]Person` 中保存的是 **值对象** ，因此通过任意方式获取的都是 **值对象的副本** ， 所有修改都是在副本上， **不能** 修改真实值。

![image-20210907221804332](/assets/img/post/2021/2021-09-07-golang-map-struct-value-modify/image-20210907221804332.png)

如果是 `map[string]*Person` 就很方便了。 `*Person` 是 **指针对象** ， 获取到的是 **指针对象的副本**， 而 **指针副本** 也指向了原始数据， 就 **可以修改** 真实值。



![image-20210907222020662](/assets/img/post/2021/2021-09-07-golang-map-struct-value-modify/image-20210907222020662.png)



## 虽然不能被修改， 但是能被覆盖



然而， map 本身可以被 **被认为** 是一个指针对象。 因此可以通过 **同名 key** 赋值覆盖的方式， **实现** 修改的效果。



```go
package main

import "fmt"

type Person struct {
	Age int
}

func main() {
	p1 := Person{Age: 10}
	p2 := Person{}

	pmap := make(map[string]Person)
	pmap["p1"] = p1
	pmap["p2"] = p2

	for key := range pmap {
		p := pmap[key] // 获取值对象

		if p.Age == 0 {
			p.Age = 18  // 修改
		}
		pmap[key] = p // 同名 key 赋值覆盖
	}

	fmt.Println(pmap)  // map[p1:{10} p2:{18}]
  
}

```

![image-20210907222503987](/assets/img/post/2021/2021-09-07-golang-map-struct-value-modify/image-20210907222503987.png)



这种虽然方式效率不高， 但是可行。
