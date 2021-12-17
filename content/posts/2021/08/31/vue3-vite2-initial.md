---
date: "2021-08-31T00:00:00Z"
description: vue3 vite2 初始化
featuredImagePreview: topic/vue.png
keywords: vue3, vite2
tags:
- vue3
title: vue3 使用 vite2 初始化项目
typora-root-url: ../../
---

# vue3 使用 vite2 初始化项目

 `vue3 + vite2 + typescript` 配置

## 使用 `vite2` 创建项目

```bash
# 交换式
yarn create vite


# 非交互式
yarn create vite project-name --template vue-ts

```

创建项目之后， `cd project-name` 进入项目， 是用 `yarn` 安装依赖， 使用 `yarn dev` 运行程序。

## 安装 less 支持

`less`  是 `css` 的一个超集。

```
yarn add less
```

安装之后， 可以在 `CompName.vue` 中使用 `less` 语法

```html
// CompName.vue
<template>
  <div class="div1">
    <h3>div1</h3>
    <div class="div2">
      <h3>div2</h3>
    </div>
  </div>
</template>

<style lang='less'>
  .div1{
    backgroud-color: skyblue
    .div2{
      backgroud-color: green
    }
  }
</style>
```

## link

[vue3 安装 vue-router支持](/2021/09/28/vue3-vue-router/)
[vue3 使用 @ 路径别名](/2021/09/28/vue3-with-alias-path/)
