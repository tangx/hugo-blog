---
date: "2021-09-06T00:00:00Z"
description: golang 中的环境变量操作
keywords: golang
tags:
- golang
title: golang 中的环境变量操作
typora-root-url: ../../
---

# golang 中的环境变量操作

golang 中的环境变量操作都在 `os` 包下面， 只有很少的几个， 而且字面意思也很明确。 

1. 所有环境变量操作对象都是 **字符串 (string)**， 因此对于 **int， bool** 类型需要自己实现转换。

2. golang 程序执行的时候， 是在 linux 系统中 **fork** 的一种子进程中

   1. golang程序 在 **复制了 fork 时 （开始运行的那一瞬间）的所有变量**， 之后的父进程中的变量变化不再影响 golang 程序。 
   2. golang 程序对环境变量的所有操作，都是在自身的子进程中，因此 **只会影响 golang 程序本身**。
   3. go 语言中没有类似 bash 中的 `export` 的操作。

   

![image-20210907001155092](/assets/img/post/2021/2021-09-06-golang-os-env-operation/image-20210907001155092.png)



## `os.Setenv("key","val")`

创建一个环境变量



## `os.Unsetenv("key")`

取消一个变量



## `val=os.Getenv("key")`

返回一个变量的值。 如果变量不存在， val 为空字符串。 `len(val)==0`



## `val,ok=os.LookupEnv("key")`

返回一个变量的值 与 变量是否存在的 bool 结果。

+ 如果变量存在， val 为值， ok 为 `true`

+ 如果变量不存在， val 为空字符串， ok 为 `false`



> 注意， **变量不存在  `(ok=true)`**, 和 **变量值为空 `(ok=false)`** 不一样



## `os.Clearenv()`

清空所有变量。



## `envs=os.Environ()`

返回包含所有变量的 `[]string` 切片 **副本** 。

由于 `os.Environ()` 返回的是一个 `[]string`  切片， 在某些场景下， 如果要进行 **传递并检索** 的时候， 并不是很方便， 因此会有需求转换成 `map[string]string` 。 

在这里， 需要额外小心， 如果在转换时使用了 `strings.Split` 而没有使用 `strings.Join` 可能会造成数据丢失。 

因为一下语句时合法的。

```bash
VAR=key1=val1,key2=val2
```



例如下面这段代码,  [envutils - fix: lost value when trans env string slice into map](https://github.com/tangx/envutils/commit/ca10e1c057193283ef308ae708ef421de3d1ec1b)





```go
	_ = os.Setenv("VAR", "key=val1,key2=val2")
	m := make(map[string]string)
	envs := os.Environ()

	for _, pair := range envs {
		kv := strings.Split(pair, "=")
    // m[kv[0]] = kv[1:] // wrong: VAR=key1 与实际情况不符合
		m[kv[0]] = strings.Join(kv[1:], "=")  // 注意这里要使用 Join
	}
```



## `os.ExpandEnv("string")`  or `os.Expand("string",os.Getenv)`

如果 string 中包含 `$key` 或者 `${key}`  的 **占位符** ， 则将被替换为实际的值。就是 `bash` 中的变量用法。

```go
func Test_ExpandEnv(t *testing.T) {
  
	_ = os.Setenv("MY_Age", "18")
	_ = os.Setenv("MY_Name", "Zhangsan")

	result := os.ExpandEnv("my name is ${MY_Name}, i'm $MY_age years old")
	fmt.Println(result) // my name is Zhangsan, i'm  years old
}
```



