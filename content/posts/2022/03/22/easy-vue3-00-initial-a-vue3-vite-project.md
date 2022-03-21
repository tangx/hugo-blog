---
title: "easy vue3 - 00 使用 vite 初始化 vue3 项目"
subtitle: "Easy Vue3 00 Initial A Vue3 Vite Project"
date: 2022-03-22T07:29:16+08:00
lastmod: 2022-03-22T07:29:16+08:00
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

<!--more-->

vite 是 vue 官方出品的一款静态服务器， 不仅可以根据多种预设模版快速创建项目， 还可以按需构建变化页面， 速度非常快。


> https://cn.vitejs.dev/guide/

## 项目初始化

使用如下命令，根据操作提示进行

```bash

yarn create vite


# yarn create v1.22.11
# [1/4] 🔍  Resolving packages...
# [2/4] 🚚  Fetching packages...
# [3/4] 🔗  Linking dependencies...
# [4/4] 🔨  Building fresh packages...
# success Installed "create-vite@2.8.0" with binaries:
#       - create-vite
#       - cva

### 输入项目名称
# ? Project name: › my-vite-project

### 选择框架
# ? Select a framework: › - Use arrow-keys. Return to submit.
#     vanilla
# ❯   vue
#     react
#     preact
#     lit
#     svelte

### 选择语言模式， 
# ? Select a variant: › - Use arrow-keys. Return to submit.
#     vue     # js 语言
# ❯   vue-ts  # ts 语言

### 创建成功
# Scaffolding project in /private/tmp/my-vite-project...
# Done. Now run:
```

随后根据提示， 进入项目目录， 执行命令安装依赖启动服务即可

```bash
cd my-vite-project
yarn
yarn dev


#   vite v2.8.6 dev server running at:

#   > Local: http://localhost:300/
#   > Network: use `--host` to expose

#   ready in 302ms.

```

访问 `http://localhost:3000/` 即可访问页面


![20220322074048](https://assets.tangx.in/blog/easy-vue3-00-initial-a-vue3-vite-project/20220322074048.png)


## 项目目录

```bash

./main.ts # 项目入口
./App.vue # 页面入口
./components/*.vue # 组件库

./package.json   # es 配置
./tsconfig.json  # ts 配置
./vite.config.ts # vite 配置


## vscode vue3 插件

+ vscode-typescript-vue-plugin: https://marketplace.visualstudio.com/items?itemName=johnsoncodehk.vscode-typescript-vue-plugin
+ volar : https://marketplace.visualstudio.com/items?itemName=johnsoncodehk.volar

