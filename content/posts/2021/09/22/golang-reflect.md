---
date: "2021-09-22T00:00:00Z"
description: Golang 反射
featuredImagePreview: topic/golang.png
keywords: golang
tags:
- golang
- reflect
title: golang 反射
typora-root-url: ../../
---

# golang 反射

golang 反射很好用， 也有很多坑。

代码在:  https://github.com/tangx-labs/golang-reflect-demo



## Kind 和 Type

在 golang 的反射中， 有两个可以表示 **类型** 的关键字， `Kind` 和 `Type` 。



### 定义覆盖范围

`Kind` 的定义覆盖范围必 `Type` 要大。 `Kind` 在定义上要 **更抽象**， `Type` 要更具体。

可以简单理解为，  如果 `Kind` 是 **车** ， 那么 `Type` 可能是 **公交车 、 消防车**



### 内置类型字面值

> https://github.com/tangx-labs/golang-reflect-demo/blob/master/kind_type_test.go#L10

虽然 `Kind` 的定义比 `Type` 要大， 但是在 **内置** 类型的时候，它们两的字面值 **可能** 是一样的。 **也可能不一样**。

```go
// kind_type_test.go

// 打印 kind 和 type 的值
func kind_type_value(v interface{}) {
	rv := reflect.ValueOf(v)
	fmt.Println(rv.Kind(), rv.Type())
}

// kind 和 type 相同字面值
func Test_Kind_Type_Same(t *testing.T) {
	name := "tangxin"
	age := 18

	kind_type_value(name) // string string
	kind_type_value(age)  // int int

	kind_type_value(&name) // ptr *string
	kind_type_value(&age)  // ptr *int
}
```

### 自定义类型

如果是自定义类型， 那 `Kind` 和 `Type` 的字面量必然不一样， 哪怕自定类型是内置类型的扩展。

```go
// 根据内置类型 string 的自定义类型
type MyString string

// kind 和 type 不同
func Test_KindType_Different(t *testing.T) {
	p := Person{
		Name: "tagnxin",
		Age:  18,
	}
	kind_type_value(p)  // struct main.Person
	kind_type_value(&p) // ptr *main.Person

	s1 := MyString("tangxin")
	kind_type_value(s1)  // string main.MyString
	kind_type_value(&s1) // ptr *main.MyString
}
```

其实这些都没什么用。

## golang 反射三定律



###  定律一:  `接口类型对象` 可以转换为 `反射对象`

> https://github.com/tangx-labs/golang-reflect-demo/blob/master/rule1_test.go#L10

通过 `reflect.TypeOf(v)` 和 `reflect.ValueOf` ，可以将 `interface{}` 转为为 **反射对象**。 其中 `reflect.Type` 表示 **反射对象类型**,  `reflect.Value` 表示 **反射对象的值**。

```go
// 第一定律: 对象类型转指针类型
func Test_Rule1(t *testing.T) {
	p := &Person{
		Name: "zhangsan",
		Age:  18,
		Addr: struct {
			City string
		}{
			City: "chengdu",
		},
	}
	rule1(p)  // ptr *main.Person
	rule1(&p) // ptr **main.Person
}

func rule1(v interface{}) {
	rv := reflect.ValueOf(v)
	fmt.Println(rv.Kind(), rv.Type())
}
```

 

### 定律二:  `反射对象` 可以转换为 `接口对象`

> https://github.com/tangx-labs/golang-reflect-demo/blob/master/rule2_test.go#L25

反射对象使用 `rv.Interface()` 可以被还原为 **接口对象** 。具体一个对象能否被还原， 可以通过 `rv.CanInterface()`  进行检查。

1. 接口检查: `rv.CanInterface()` 判断是否可以被转换成 **Interface** 类型
2. 类型转换: `irv:=rv.Interface()` 将 **反射类型 rv** 转换为 **interface** 类型
3. 类型断言: 常规操作了， `v,ok:=irv.(type)` 。

```go
func rule2(rv reflect.Value) {
	// check
	if !rv.CanInterface() {
		fmt.Println("rv is not settable: ", rv.Type())
		return
	}

	// convert
	rv = DerefValue(rv)
	irv := rv.Interface()
	fmt.Println(irv)

	// type assert
	v, ok := irv.(Person)
	fmt.Println(v, ok) // {zhangsan 18 {chengdu}} true

}
```



### 定律三:  反射类型如果要修改值， 则反射类型必须为 settable

> https://github.com/tangx-labs/golang-reflect-demo/blob/master/rule3_test.go#L32

1. 修改行为检查: `rv.CanSet()` 判断是否能进行值修改
2. 修改值: golang reflect 包提供了很多对应类型的修改， 结构统一为 `rv.SetXXXX(value)`
   1. `SetString(s)`
   2. `SetInt(i)`
   3. `SetBool(b)`
   4. https://pkg.go.dev/reflect#Value.SetBool

```go
func rule3(rv reflect.Value) {
	if !rv.CanSet() {
		fmt.Println("rv is not settable", rv.Type())
		return
	}

	switch rv.Kind() {
	case reflect.String:
		rv.SetString("tangxin")
	case reflect.Int:
		rv.SetInt(333)
	default:
		fmt.Println("not support kind: ", rv.Kind())
	}
}
```





## reflect.Type 和 reflect.Value

 `reflect.Type`  和  `reflect.Value` 是反射中基础的基础。 

###  `反射指针对象` 类型 与  `反射容器对象` 类型

**指针** 在 golang 中是一个比较特别的对象， 万事万物， 都可以获取到指针。在反射对象中也不例外。 

**反射容器对象**  这个名字是我自己取的， 就是为了区别于 **反射指针对象**  以便随后阐述。 其实在 golang 的 `reflect.Kind` 定义中， **指针** 与 **容器** 对象是平级的。

```go
const (
	Invalid Kind = iota
	Bool
	Int
  // ...
  String
  // ...
	Interface
	Map
	Ptr  // 这里是重点， 指针可以只想任何容器类型，包括指针本身。
)
```



#### 指向指针的指针对象

如果需要通过 `*main.Person` 的 **反射指针对象 `p`** 需要获取真实对象类型  `main.Person` ，可以使用  `p.Elem()` 方法。 **但是**， 如果 `p` 不是 **指针对象** 将会发生 `panic`。

因此， golang 提供了 `reflect.Indirect(rv)` 方法获取真实对象类型。当 p 为指针时， 返回 `p.Elem()`, 否则返回 `p` 本身。

```go
func Indirect(v Value) Value {
	if v.Kind() != Ptr {
		return v
	}
	return v.Elem()
}
```

但这里本身也有一个问题， `p ` 是一个 **指向指针的指针** ，如果值使用一次 `reflect.Indirect()` 可能得到的依旧是一个指针对象。 

概念有点绕， 但确实存在， 例如结果如下 `**main.Person` 。

```go
// rule1_test.go
// 指向指针的指针对象
func Test_Rule1(t *testing.T) {
	p := &Person{
		Name: "zhangsan",
		Age:  18,
		Addr: struct {
			City string
		}{
			City: "chengdu",
		},
	}

	rv := reflect.ValueOf(&p)
	fmt.Println(rv.Kind(), rv.Type()) // ptr **main.Person
}


```

在如此情况下， 在单独使用 `reflect.Indirect()` 就不好用了。 

因此可以适当改造一下, 这样就可以保证不论有多少层 **指针**， 都可以拿到真实的的 **反射容器对象**

```go
// value.go
// DerefValue 返回最底层的反射容器对象
func DerefValue(rv reflect.Value) reflect.Value {
	for rv.Kind() == reflect.Ptr {
		rv = rv.Elem()
	}

	return rv
}
```

同理， `reflect.Type` 也有这种情况。

> https://github.com/tangx-labs/golang-reflect-demo/blob/master/type.go#L5
>
> https://github.com/tangx-labs/golang-reflect-demo/blob/master/value.go#L5



### 获取 `reflect.Type`

一个对象 `v` 的 **反射类型** 有两种方式获取。 

+ `reflect.TypeOf`  
+ `rv.Type()`

这两者的结果是相同的。



## 结构体方法调用

> https://github.com/tangx-labs/golang-reflect-demo/blob/master/method_call_test.go#L31

调用结构体的方法， 也是 golang 反射中一个重要的特点。

1. 使用 `mv:=rv.MethodByName(name)`  返回一个
2. 使用 `mv.IsValid()` 检查对象是否合法。
3. 使用 `mv.Call(...In)` 调用方法。

需要额外注意的是：

1. 方法的 **接收者** 是有 **指针 `(s *student)`** 和 **结构体 `(s student)`** 之分的。
2. 在反射对象中 **指针接收者** 的方法是不能被 **结构体接收者** 调用。

```go

type student struct {
	Name string
	Age  int
}

func (stu *student) SetDefaults() {
	stu.Name = "tangxin"
	if stu.Age == 0 {
		stu.Age = 100
	}
}

// 没有传参数的方法
func (stu *student) Greeting() {
	fmt.Printf("hello %s, %d years old\n", stu.Name, stu.Age)
}

// 具有传参数的方法
func (stu *student) Aloha(name string) {
	fmt.Println("aloha,", name)
}

func Test_MethodCall(t *testing.T) {
	stu := student{
		Name: "wangwu",
	}

	// 注意
	// 方法对象的方法接收者， 可以是 **指针对象** 也可以是 **结构体对象**
	// 如果是指针对象的方法， **结构体对象** 是不能调用起方法的
	rv := reflect.ValueOf(stu)
	prv := reflect.ValueOf(&stu)

	stu.Greeting()
	methodCall(prv, "SetDefaults")
	methodCall(rv, "Greeting") // 结构体接收者， 找不到方法
	methodCall(prv, "Aloha", reflect.ValueOf("boss"))
}

// 对象方法调用
// rv 目标对象, method 方法名称, in 参数
func methodCall(rv reflect.Value, method string, in ...reflect.Value) {

	// 通过方法名称获取 反射的方法对象
	mv := rv.MethodByName(method)
	// check mv 是否存在
	if !mv.IsValid() {
		fmt.Printf("mv is zero value, method %s not found\n", method)
		return
	}

	// 调用
	// nil 这里代表参数
	mv.Call(in)
}

```

