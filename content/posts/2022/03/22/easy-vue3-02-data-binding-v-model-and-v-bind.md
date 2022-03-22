---
title: "Data Binding v Model and v Bind"
subtitle: ""
date: 2022-03-22T22:01:23+08:00
lastmod: 2022-03-22T22:01:23+08:00
draft: false
author: ""
authorLink: ""
description: ""

tags: []
categories: []

hiddenFromHomePage: false
hiddenFromSearch: false

featuredImage: ""
featuredImagePreview: ""

toc:
  enable: true
math:
  enable: false
lightgallery: false
license: ""
---

Vue 中有两种数据绑定方式：

1. `v-bind` 单向绑定: 数据只能从 data 流向页面
2. `v-model` 双向绑定: 数据不仅能从 data 流向页面， 还可以从页面流向 data.
  + `v-model` 一般用在 **表单类型元素** 上 (ex, input, select)。
  + `v-model` 需要省略 `v-model:value` 中的 value ， 因为 v-model 默认收集的就是 value 值。

> `v-model:value` 会提示错误: v-model argument is not supported on plain elements.vue(55)



```html
<template>
<h1>02 数据绑定 v-bind and v-model</h1>
1. v-bind 数据单向绑定 <input type="text" v-bind:value="name"/>
<br>
2. v-model 数据双向绑定 <input type="text" v-model="name"/>
<hr>
</template>

<script setup lang='ts'>import { ref } from 'vue';
let name = ref("zhangsan")
</script>
```

![20220322221633](https://assets.tangx.in/blog/easy-vue3-02-data-binding-v-model-and-v-bind/20220322221633.png)
