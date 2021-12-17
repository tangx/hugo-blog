---
date: "2021-08-25T00:00:00Z"
description: typescript 中的时间处理
keywords: typescript, time
tags:
- typescript
title: typescript 中的时间处理
---

# typescript 中的时间处理



在 `typescript/ javasctipt` 中， **时间** 是一个 **构造** 函数， 需要通过 `const dt = new Date(xxx)` 进行初始化创建时间对象。



## 创建时间对象



```ts
// 获取当前时间对象
const now = new Date()

// 将字符串时间转换为 Date 时间对象
const timeStr = '2021-08-23T02:42:17Z'
const dt = new Date(timeStr)

// 根据数字创建时间
const dt2 = new Date(Date.UTC(2006, 0, 2, 15, 4, 5));
console.log("event:::", dt2);
```



## 时间操作



### 获取时间对象的属性值

通过 `getXXX()` 方法， 可以获取时间对象的具体属性至。

```ts
// 将字符串时间转换为 Date 时间对象
const timeStr = '2006-01-02T13:04:05Z'
const dt = new Date(timeStr)
console.log("dt:::", dt)  // dt::: 2006-01-02T13:04:05.000Z
// 获取时间信息
const year = dt.getFullYear() // 2021
const month = dt.getMonth() // 8
const date = dt.getDate() // 23
console.log(`${year}-${month}-${date}`); // 2021-7-23

```

> 注意： 由于奇奇怪怪的原因， month 的取值范围是 `0-11` ， 也就是说 0 -> 1月，11 -> 12月。



### 时间对象转字符串



通过 `toXXXString()` 方法，可以将时间转化为字符串对象。 **但是** 大多数转换结果都和本地时区和语言设置有关。



#### `toISOString()`

其中， `toISOString()` 方法返回一个 ISO格式的字符串： `YYYY-MM-DDTHH:mm:ss.sssZ`。时区总是UTC（协调世界时），加一个后缀 `Z` 标识。

```ts
const dtStr = dt.toISOString()
console.log("toISOString,,,", dtStr) // 2006-01-02T13:04:05.000Z
```



#### `toJSON()`

返回一个 时间对象的字符串， 常用于 JSON 序列化， 内部使用 `toISOString()` ，所以输出格式是一样的。

```ts
const dtJSonStr = dt.toJSON() // 2006-01-02T13:04:05.000Z
```



### 时间对象比较

时间对象是可以直接通过 `比较符` 比较的，可以看作转换成 `timestamp` 数字后的大小比较。

```ts
// 时间比较
// dt: 2006-01-02 
// now: 2021-08-23
if (dt > now) {
    console.log("dt > now = ", true) // 不会结果显示， 因为条件为假
}
console.log("dt > now = ", dt > now)  // false
```



### 修改时间



使用 `setXXX()` 方法

```ts
const event = new Date('December 31, 1975 23:15:30 GMT-3:00');

console.log(event.getUTCFullYear());
// expected output: 1976

console.log(event.toUTCString());
// expected output: Thu, 01 Jan 1976 02:15:30 GMT

event.setUTCFullYear(1975);

console.log(event.toUTCString());
// expected output: Wed, 01 Jan 1975 02:15:30 GMT
```



### 相对时间操作

`typescrtip` 本身没有提供 **时间对象** 的 **获取相对时间**  的操作方法。 可以通过 `setXXX()` 方法来时间

> 注意:  setXXX() 返回会修改时间 **`对象本身`**。

```ts
// 获取当前时间
const now = new Date()
console.log("now:::", now) // now::: 2021-08-25T10:07:43.932Z

// 修改时间
const delta = now.getFullYear() + 1
now.setFullYear(delta)

// console.log NOW <<<<
console.log("1 year laster, now:::", now);  // 1 year laster, now::: 2022-08-25T10:07:43.932Z

```





## 时间深拷贝



由于 `setXXX()` 是会修改原数据的， 那么一些时候， 就需要用到时间的**深拷贝**。 核心思想就是通过 **序列化/反序列化** 完成一个 **全新时间对象** 的创建， 当然，其字面值是相同的。

```ts
// 深度拷贝
const now2 = new Date(now.toJSON())

console.log(now2, now) // 2022-08-25T10:24:31.700Z 2022-08-25T10:24:31.700Z

console.log(ow2 == now)  // false 时间对象对比
console.log(now2 >= now)  // true 时间对象对比
console.log(now.toJSON() === now2.toJSON()) // true 字面值对比

```

