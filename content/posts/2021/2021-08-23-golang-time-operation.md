---
date: "2021-08-23T00:00:00Z"
description: golang 中的时间处理
keywords: golang
tags:
- golang
title: golang 中的时间处理
---



# golang 中的时间处理



在 `golang` 中有一个**很重要的** 格式化时间的字符串 `2006-01-02T15:04:05Z07:00` ， 这个也是 golang 默认时间模版模版中的 `time.RFC3339`

```go
	RFC3339     = "2006-01-02T15:04:05Z07:00"
```

golang 中关于时间的处理， 用到了上面的 **每一个** 数字和字母。 

>  需要特别注意的是， 时区用的是 **7** 而非 **6** ， 因为 **6** 已经在 **年（2006）** 中出现了



## 创建时间对象 `time.Time`



```go
// 1. 创建当前时间对象
	now := time.Now()

// 2. 通过各个字段创建时间对象
	t1 := time.Date(2019, time.November, 17, 11, 0, 0, 0, time.UTC)

// 3. 通过 time.Parse 解析字符串创建时间对象
	FORMAT = `2006-01-02T15:04:05Z`
	timeStr := `2019-11-23T15:23:31Z`
	t, err := time.Parse(FORMAT, timeStr)
```

1. 这里需要注意的是， `time.Parse()` 解析字符串创建时间对象时， **FORMAT** 中出现的数字和字母必须是 golang 定义的， 不能随意替换。

2. **所有时间对象** 都是有 **时区** 属性的， 如果没有指定， 默认使用 **UTC** 时间即 **0 时区**
3. 但是 **time.Now()** 默认返回的是当前运行 **时区** ， 因此在做时间对比的时候， **切记** 要统一时区。





## 时间操作



### 获取时间对象的属性值

在获取属性值的时候，可以直接通过 `t.XXX()` 方法获取， 且 `XXX` 方法名具有特别强的 **语意** 。

```go
	now := time.Now() // 2021-08-25T
	
	now.Year()    // 2021  年
	now.Month()   // August int(xxx)
	now.Day()     // 25

	now.YearDay() // 237
	now.Date()    // 2021 August 25

// ...
```

1. `now.Month()` 返回的是 `Month` 的 **自定义类型** `type Month int` ， 其底层类型是 `int` ， 可以通过 `int(Month)` 进行转换。
2. `now.YearDay()` 返回是 **一年中的第几天** 。
3. `now.Date()` 返回 **年 月 日** 



### 时间对象转字符串



#### `t.String()`

`t.String()` 内置了一个 `FORMAT` 字符串，并使用了 `t.Format()` 进行格式化， 

```ts
now.String() // 2021-08-25 22:15:47.467594 +0800 CST m=+0.000505982
```



#### `t.Format()`

`t.Format(FOMART)` 方法允许用户自定义传入自定义的 `FOMART` 格式， 以输出想要的格式

```go
t.Format(time.RFC1123)  // time.RFC1123 :  Wed, 25 Aug 2021 22:15:47 CST
t.Format(time.RFC822Z)  // time.RFC822Z :  25 Aug 21 22:15 +0800
t.Format(time.RFC3339)  // time.RFC3339 :  2021-08-25T22:15:47+08:00
```



#### `t.MarshalXXX() ([]byte,error)` `

`t.MarshalText()` 与 `t.MarshalJSON` 默认使用的是 `RFC3339` 格式字符串。 不同的是， `MarshalJSON` 在外层包裹了一对 **双引号** 

```go
	now := time.Now()

	b, _ := now.MarshalJSON()
	fmt.Printf("%s\n", b)   // "2021-08-25T22:27:49.009467+08:00"


	b2, _ := now.MarshalText()
	fmt.Printf("%s\n", b2)  // 2021-08-25T22:27:49.009467+08:00

```



### 时间对象比较

golang 中非常友好的提供了 `t.Before(), t.After(), t.Equal()` 方法进行时间比较。

```go
t1, _ := time.Parse("2006-01-02T15:04:05Z", "2021-09-20T10:12:30")
t2, _ := time.Parse("2006-01-02T15:04:05Z", "2021-08-20T10:12:30")

fmt.Println(t1.After(t2))  // false
fmt.Println(t1.Equal(t1))  // true
```



### 时间偏移

1. `t.Sub()` 可以求出两个时间的 **时间差 `time.Duration` ** 。

2. `t.Add()` 与**时间差 `time.Duration`** 可以创建一个新的 `time.Time` 时间对象。

> time.Duration 可以为 **正数** 和 **负数** 。

3. `t.AddDate()` 可以方便的创建变更年月日， 创建新时间对象

```go
	t1 := time.Now() // 2021-08-25 ...

	time.Sleep(time.Second * 1)
	t2 := time.Now()

	d1 := t1.Sub(t2)
	fmt.Println(d1.Seconds())  // -1.003566082

	t3 := t2.Add(-24 * time.Hour)  
	fmt.Println(t3)  // 2021-08-24 ...

	t4 := t2.AddDate(-1, -1, -1)
	fmt.Println(t4)   // 2020-07-24 ...
```

