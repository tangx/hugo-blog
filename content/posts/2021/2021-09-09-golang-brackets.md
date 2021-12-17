---
date: "2021-09-09T00:00:00Z"
description: golang 括号用法总结
keywords: golang
tags:
- golang
title: golang 括号用法总结
typora-root-url: ../../
---

# golang 括号用法总结



```go
var (
   f unsafe.Pointer
   a io.ReadCloser = (*os.File)(f) // 只要是一个指针就可以
   b io.Reader = a // a的方法集大于等于b，就可以做隐式的转换！
   c io.Closer = a  // 同样
   d io.Reader = c.(io.Reader)  // 显式转换，c这个接口很明显方法集和io.Reader不同
   // 但是万一传入c的对象拥有io.Reader接口呢？比如
)
```



提问， 以上这些括号都是做什么用的。





## 圆括号

### 1. `函数/方法` 中的 `传参` 与 `返回值`

```go
func add(x,y int) (int,error){
  return x+y, nil
}
```



### 2.`结构体` 中的方法 `接收者`

```go
type Person struct {
  Name string
}

func (p *Person) String() string{
  return p.Name
}
```



### 3. 四则运算优先级

```go
i:=1*(2+3)
```



### 4. 显示类型转换

```go
a:=int(100)

d:=time.Duration(1 * time.Second)
```



### 5. 类型断言

```go
func output(x interface{}) {
	v, ok := x.(string)
	if ok {
		print(v)
	}
}
```



### 6. 复杂对象的边界

```go
type User struct{}

func (u *User) Show() {
	fmt.Println("hello. buddy")
}

func main() {
	(&User{}).Show()  // 这里
}

```



### 7.  `var / const / import` 组

```go
import (
	"fmt"
	"time"
)

var (
	a = 1
	b = 2
)

const (
	c = 3
	d = 4
)
```



## 花括号/大括号

一句话归纳，就是作用于

### 1. 数据集合

`map`, `slice`, `array`

```go
func main() {

	parts := []int{1, 2, 3}
	arr := [3]int{1, 2, 3}
	m := map[string]string{"a": "b", "c": "d"}

}
```



### 2. 关键字作用域

1. 控制逻辑

   + `if / else`
   +  `for`
   + `select` 
   +  `switch`

2. 类型定义

   + `struct` 

   +  `interface`

3. 函数体

   + `func`

```go
func main(){
	for {
		// statment
    switch i{
    case 1:
      // statement
    default:
     	// statement
    }
	}
}
```



### 3. 匿名代码块 / 独立作用域

```go
fun main(){
  i:=3
  {
    i:=3
    // statement
  }
}
```



## 方括号

### 1. `map` 的类型

```go
	m := map[string]string{"a": "b", "c": "d"}
```



### 2. 数组的长度

```go
	arr1 := [3]int{1, 2, 3}
	arr2 := [...]int{1, 2, 3, 4, 5}
```



### 3. 切片定义

```go
nums := []int{1, 2, 3}
```



### 4. 元素索引

```go
	a := m["a"]
	n1 := arr2[0]
	n2 := nums[1]
```



### 5. 泛型类型 go1.17 及以后

1. 函数定义， 定义传参**泛型**类型 : `add[T Addable](a,b T)`
2. 函数调用， 指定传参**特定**类型: `add[int]("a","b")`

```go
package main

import "fmt"

func main() {
	add(1,2)
	add("a","b")
	// add[int]("a","b") // 错误， 强制约束了传入为 int 类型
}


type Addable interface {
	type int,string
}

func add[T Addable](a,b T) {  
	fmt.Println(a+b)
}
```

