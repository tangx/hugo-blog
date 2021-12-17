---
date: "2021-12-14T00:00:00Z"
description: golang deepcopy 的两种实现方式
featuredImagePreview: topic/golang.png
keywords: go, deepcopy
tags:
- cate1
- cate2
title: golang deepcopy 的两种实现方式
typora-root-url: ../../
---

# golang deepcopy 的两种实现方式

最近在基于 gin 封装 [rum-gonic - github](https://github.com/go-jarvis/rum-gonic/) web 框架的过程中，遇到了一个问题。 

在注册路由的时候传递是 **指针对象**， 因此造成所有的 request 请求使用相同的 `CreateUser` 对象, 出现并发冲突。

```go
func init() {
	RouterGroup_User.Register(&CreateUser{})
}

type CreateUser struct {
	httpx.MethodPost `path:""`
	Name     string `query:"name"`
	Password string `query:"password"`
}
```



## struct 结构体 deepcopy 的实现

基于 `sturct` 的实现， 由于有 **明确** 的 `struct` 对象结构， 通常直接创建一个全新对象， 同时把老数据复制进去。 

例如 [gin-gonic 的 `Copy()` 方法](https://github.com/gin-gonic/gin/blob/84d927b8ad57ed9e1cda240b41fa2eed55066103/context.go#L107)

```go
// Copy returns a copy of the current context that can be safely used outside the request's scope.
// This has to be used when the context has to be passed to a goroutine.
func (c *Context) Copy() *Context {
	cp := Context{
		writermem: c.writermem,
		Request:   c.Request,
		Params:    c.Params,
		engine:    c.engine,
	}
	cp.writermem.ResponseWriter = nil
	cp.Writer = &cp.writermem
	cp.index = abortIndex
	cp.handlers = nil
	cp.Keys = map[string]interface{}{}
	for k, v := range c.Keys {
		cp.Keys[k] = v
	}
	paramCopy := make([]Param, len(cp.Params))
	copy(paramCopy, cp.Params)
	cp.Params = paramCopy
	return &cp
}
```

## interface 接口 deepcopy 的实现

对于 **接口 `interface{}`** 就稍微麻烦一点了。  由于 **接口** 是一组方法的集合， 也就意味着

1. 接口的 **底层结构体** 是不定的。
2. 无法直接获取 **底层结构体** 的字段数据。

这时可以通过使用 **反射** `reflect.New()` 创建对象。

[mohae/deepcopy - github](https://github.com/mohae/deepcopy/blob/c48cc78d482608239f6c4c92a4abd87eb8761c90/deepcopy.go#L39) 就是使用的这种方式 

deepcopy 库中一样通过 **反射递归** 实现复制， 是为了兼容更多的情况。
而在自己实现编码的时候， 大部分情况的是可控的， 实现方式可以适当简化， 不用与 deepcopy 完全相同。

### 1. 通过反射创建零值接口对象

```go
func deepcoper(op Operator) Operator {
	// 1. 获取 反射类型
	rt := reflect.TypeOf(op)

	// 2. 获取真实底层结构体的类型
	rtype := deRefType(rt)

	// 3. reflect.New() 创建反射对象，并使用 Interface() 转真实对象
	opc := reflect.New(rtype).Interface()

	// 4. 断言为 operator
	return opc.(Operator)
}

func deRefType(typ reflect.Type) reflect.Type {
	for typ.Kind() == reflect.Ptr {
		typ = typ.Elem()
	}

	return typ
}
```

需要注意的是， 通过上述方式创建的出来的新对象

1. **依然** 不知道新接口底层结构体是什么， **也并不需要关心**， 接口中心本身就是在 **相同的方法实现** 上。
2. 接口底层结构体中所有字段值为 **零值**， 可能需要必要的初始化，否则直接使用可能 `panic`， 例如结构体中存在 **指针类型对象** 。


通常这种情况， 在自己写代码的时候，可以增加一个 **初始化方法** 。

### 2. 使用接口断言进行初始化

在实现了初始化方法之后， 可以再定义一个接口。 通过断言转化为新接口， 调用初始化方法。

```go
func deepcoper(op Operator) Operator {
	rt := reflect.TypeOf(op)

	rtype := deRefType(rt)

	opc := reflect.New(rtype).Interface()

	// 3.1. 使用断言转化新接口， 初始化底层对象
	if opcInit, ok := opc.(OperatorIniter); ok {
		opcInit.SetDefaults()
	}

	return opc.(Operator)
}

type OperatorIniter interface {
	SetDefaults()
}
```

### 3. 使用反射调用方法进行初始化

在不增加新接口的情况下， 可以在反射创建的过程中 **判断初始化方法的存在， 并调用** 进行初始化。

```go

func deepcoper(op Operator) Operator {
	rt := reflect.TypeOf(op)
	rtype := deRefType(rt)
	ropc := reflect.New(rtype)

	// 3.2 使用反射 call method 初始化
	method := ropc.MethodByName("SetDefaults")
	if method.IsValid() && !method.IsZero() {
		method.Call(nil)
	}

	opc := ropc.Interface()
	return opc.(Operator)
}

```

## 搞点看起来高级的: 接口初始化工厂

上述代码中都是直接对接口对象进行的操作。 搞一个 struct 创建并初始化接口， 可以携带和组织更多的信息。

```go
func NewOperatorFactory(op Operator) *OperatorFactory {
	opfact := &OperatorFactory{}

	opfact.Type = deRefType(reflect.TypeOf(op))
	// opfact.Operator = op
    
	return opfact
}

type OperatorFactory struct {
	Type     reflect.Type
	Operator Operator
}

func (o *OperatorFactory) New() Operator {

	oc := reflect.New(o.Type).Interface().(Operator)

	return oc
}
```


