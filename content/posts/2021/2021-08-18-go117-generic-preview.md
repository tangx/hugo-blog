---
date: "2021-08-18T00:00:00Z"
description: go1.17 发布了， 内置了泛型支持， 但是并未默认开启
keywords: go
tags:
- golang
title: go1.17泛型尝鲜
---

# go1.17 泛型尝鲜



语法格式如下， 需要使用 `[T Ttype]` 指定约束条件， 例如 `[T any]` 不做任何约束, `[T  MyInterface]` 满足 `MyInterface` 的约束

接下来我们将尝试上述提到的内容。

```go
func fname[T Ttype](args []T) T {
	// statement
}
```



需要注意的是， 

1. 现在泛型在 go1.17 中依旧不是正式支持， 所以在 IDE 或者编辑器上会有报错。
2. 编译需要指定额外的 `-gcflags=-G=3` 参数

```makefile
go run -gcflags=-G=3 main.go
```





## 开始吧



### 不约束 `any` 



首先，我们来一个最开放的约束， 就是不约束。

使用 `[T any]` 就好了。

**demo** 代码如下，

```go
// demo1: 尝鲜泛型
package main

import (
	"fmt"
)

// printSlice 遍历传入的数组， 打印所有元素。
func printSlice[T any](s []T){
	for _, v:=range s{
		fmt.Printf("%v ",v)
	}

	fmt.Println("")
}

func main(){
  // 注意1: 在使用时， 强制为 T 指定类型， 例如这里的 [int]
	printSlice[int]([]int{666,777,888,999,1000})
	printSlice[string]([]string{"zhangsan", "lisi","wangwu"})
  
  // 注意2: 也可以不指定， golang 自己会进行类型约束检查。
  printSlice([]float32{1.1,2.2,3.3})
}

// go run -gcflags=-G=3 main.go
// 666 777 888 999 1000 
// zhangsan lisi wangwu 
// 1.1 2.2 3.3 
```



在使用时， 需要注意：

1. 执行函数时， 可以在**函数名** 和**参数列表之间** 使用 `[type]`  指定传入参数的类型，以便 **强制约束** 此次调用的传入参数类型， 其他符合 `T` 的类型也将不能传入。
2. 也可以不指定， 那么 **golang** 会自动检查传入参数是否符合 `T` 类型。



### 使用内置类型约束



在约束 **内置类型** 时， 定义一个接口， `Addable`  在其中使用所支持的格式， 其作用有点像 `typescript` 中的的 **联合类型**



具体定义方式如下

`Addable` 就是接口名字， 也就是 `[T Addable]` 的类型。

**注意**

1. 接口中， 使用 `type` 表示支持的类型
2. 在多个支持类型之间，使用 `逗号 ,` 进行分割

```go
// Addable 定义类型约束
// 多个类型之间， 使用 逗号 , 分割
type Addable interface {
	type int,string
}
```



**demo** 如下

```go
// demo2 使用内置类型约束
package main

import (
	"fmt"
)

// Addable 定义类型约束
// 多个类型之间， 使用 逗号 , 分割
type Addable interface {
	type int,string
}


func main() {

  // 1. 传入 string
	r:=add("hello", "jack")
	fmt.Println(r) // hellojack


  // 2. 传入 int
	r2:=add(1,2)
	fmt.Println(r2) // 3

  // 3. 传入 int64 // 失败
	r3:=add(int64(1),int64(2))
	fmt.Println(r3)
  // error: ./main.go:21:9: int64 does not satisfy Addable (int64 not found in int, string)
}

// add 对支持类型执行 + 操作
func add[T Addable](a,b T) T{
	return a+b
}
```

从结果说知，`int64` 不是之前 `Addable` 中所支持的类型， 所以报错了。 报错也很明显 `not satisfy Addable` 不符合接口。

因此， 以后在遇到泛型报错的时候， 多注意一下报错内容，看看是否是所支持类型错误， 而减少经验错误 **明明 `int64` 支持加法，为什么不行呢？**



### 使用接口方法约束



我们都知道， 接口本身就是一种约束行为。 因此 go1.17 之前的接口思想， 同样适用。

代码中注释已经很清楚了， 就不再额外赘述解释了。



```go
// demo3: 自定义接口方法约束
package main

import "fmt"
import "strconv"

// MyStringer 定义 T 的约束接口
// 只有具有 String() string 方法的类型才能进行 printer 操作
type MyStringer interface {
	String() string
}

// MyType 结构体 及 String 方法
type MyType struct {
	name string
}
func (t MyType) String() string{
	return "mytype.name = "+t.name
}

// YourType 结构体 及 方法
type YourType struct{
	age int
}
func (t YourType)String() string{
	return "yourtype.age = "+strconv.Itoa(t.age)
}


func main() {
  // 实例化
	mt:=MyType{
		name:"zhangsan",
	}
	printer(mt)

  // 实例化
	yt:=YourType{
		age:20,
	}
	printer(yt)
}

// printer 之支持满足 MyStringer 接口的类型
func printer[T MyStringer](vals T){
  // 打印结果
	fmt.Println(vals)
}
```



## 总结 

总的来说， 在使用上， 泛型就是把之前的具体类型**往上抽了一层** ，之前是使用 **具体** 的类型约束。 现在是使用 **某种接口** 类型约束。



更多的，期待 go1.18 正式推出泛型的时候。

