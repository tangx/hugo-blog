---
title: "easy vue3 - 01 模版语法"
subtitle: ""
date: 2022-03-22T18:44:29+08:00
lastmod: 2022-03-22T18:44:29+08:00
draft: false
author: ""
authorLink: ""
description: ""

tags: [vue3]
categories: [vue3]

hiddenFromHomePage: false
hiddenFromSearch: false

featuredImage: "/assets/topic/vue.png"
featuredImagePreview: "/assets/topic/vue.png"

toc:
  enable: true
math:
  enable: false
lightgallery: false
license: ""
---


在 vue 中渲染变量通常有两种方式

1. 插值语法， 又叫 **胡子语法** ， 使用 `{{ xxx }}` 方式在 **标签体** 渲染变量

```html
<h3>插值语法: {{ name }}</h3>
```

![20220322003358](https://assets.tangx.in/blog/easy-vue-01/20220322003358.png)

2. 指令语法 `v-bind:attr="xxxx"`, `v-bind` 可以缩写为 `冒号 :`， attr 是 **标签属性** 名称； xxx 是属性标签值， 且 xxx 是 **js 表达式**

```html
<h3>指令语法</h3>
<a :href="url"> 百度一下 ( : ) </a>
<br>
<a v-bind:href="url"> 百度一下 ( v-bind ) </a>

<a date="date.Now()"> 123</a>
```

![20220322003350](https://assets.tangx.in/blog/easy-vue-01/20220322003350.png)


这里再次 **强调一下**, `xxx` 是 **js 表达式** 而非简单的变量名称。

例如， 下面例子中， 使用了字符串的转大些字母 `xxx.toUpperCase()` 的方法。 

```html
<h3>指令语法</h3>
<a :href="url"> 百度一下 ( : ) </a>
<br>
<a v-bind:href="url.toUpperCase()"> 百度一下 ( v-bind ) </a>
```

从结果中可以看到， 被渲染的 url 地址全部是大写字母

![20220322003700](https://assets.tangx.in/blog/easy-vue-01/20220322003700.png)

