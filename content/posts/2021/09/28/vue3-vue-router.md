---
date: "2021-09-28T00:00:00Z"
description: vue3 安装 vue-router 支持
featuredImagePreview: /assets/topic/vue.png
keywords: vue3, vue-router
tags:
- cate1
- cate2
title: vue3 安装 vue-router 支持
typora-root-url: ../../
---


# 安装 `vue-router` 路由支持

在 `vue3` 中使用的是 `vue-router@next` 版本 `^4.y.z`

```bash
yarn add vue-router@next
```

## `/src/router/index.ts` 创建路由规则

安装之后， 在创建文件 `/src/router/index.ts` 作为 `vue-router`  的初始化文件。

```ts
// 导入创建路由所需的组件
import { createRouter, createWebHistory } from "vue-router";

// 路由目标组件
import HelloWorld from '../components/HelloWorld.vue'
import World from '../components/World.vue'

// 路由表
const routes = [
    {
        path: "/helloworld",
        name: "HelloWorld",
        component: HelloWorld
    },
    {
        path: "/world",
        name: "World",
        component: World
    }
]

// 创建路由器
const router = createRouter({
    history: createWebHistory(),
    routes: routes,
})

// 导出默认组件
export default router
```

## `main.ts`  引用路由器

在 `/src/router/index.ts` 中， 路由器创建成功后， 需要在 `vue3` 中引用才能生效。

```ts

import { createApp } from 'vue'
import App from './App.vue'


// 默认是链式调用
// createApp(app).mount('#app')

// 修改为一下方便引入其他组件

// 导入 router
import router from './router/index'
// 创建并声明
const app = createApp(App)

app.use(router) // 使用路由
app.mount('#app') // 挂载对象
```

## 在 `CompName.vue` 使用路由规则

路由规则可以在任意 `vue SCF` 中使用， 例如  `App.vue` 作为 demo。

1. `<router-link></router-link>` 标签作为路由跳转规则， 编译后将是 `<a> </a>` 标签
   1. 在 `router-link` 中使用 `to="/path"` 指定路由对象， 即在 `index.ts` 中定义路由对象。
2. 使用 `<router-view />` 作为占位符， 指定展示区。使用 `routes` 中的 ex. `HelloWorld.vue` 将在该区域展示。

```vue
<template>
	<div class="link-container">
    <router-link to="/helloworld">Hello</router-link>|
    <router-link to="/world">World</router-link>
  </div>

	<div class="view-container">
    <router-view />
  </div>
</template>
```

