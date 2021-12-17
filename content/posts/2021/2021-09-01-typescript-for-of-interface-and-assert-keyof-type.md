---
date: "2021-09-01T00:00:00Z"
description: typescript 获取 meta 信息并注入后端地址， 实现一次编译处处部署
keywords: typescript
tags:
- typescript
title: typescript vue3 项目容器化实战
---

# typescript vue3 项目容器化实战 



在前端容器化的时候， 有一个绕不开的问题： **容器返回的后端地址应该怎么设置**。 

静态编译到所有文件中， 肯定是不可取的， 总不能后端变更一个访问域名，前端都要重新构建一次镜像吧？

由于 `js` (**typescript 编译后** ) 实际是运行在 **用户的浏览器上**， 所以也不能像后端一样读取环境变量。

所以， 通过 `html <meta>` 标签传递信息是一个很好的方法。 只需要每次 **容器启动的时候， 把 config 信息注入到 index.html** 中就可以了。



## 1. html 文件: 配置注入的 config 值

在 html 文件中使用自定义 `meta` 标签 。 `name` 为注入名称， `content` 为注入值， 使用 `k1=v1,k2=v2` 的方式。

```html
  <meta name="devkit:config" content="BaiduApi=//Dubai.api.com,QQapi=//QQ.com">
```

完整 html 如下

```html
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <!-- -->
  <meta name="devkit:config" content="BaiduApi=//Dubai.api.com,QQapi=//QQ.com">
  <title>Document</title>
  <script src="../dist/06-workflow/for-interface.js"></script>
</head>

<body></body>
</html>
```



## 2. ts 文件: 初始化 config 默认值与新值注入

1. `interface AppConfig` 定义 `Config` 字段
2. `const appConfig:AppConfig = {}` 初始化 配置
3. `function injectConfig(){}` 执行函数注入信息
   1. `document.getElementsByTagName('meta')` 获取所有 meta 标签
   2. `const item = metas.namedItem('devkit:config')` 根据 `meta name` 获取 meta 标签
   3. `item?.content`  中 `item?` 忽略 null 情况
   4. `content.split(',')` 字符串分割

```ts
// config.ts

// 定义 Config 字段
interface AppConfig {
    BaiduApi?: string
    AliApi: string
}

// 实例化 config 并赋予默认值
//   外部导入时  import { appConfig } from '@/apis/config.ts'
export const appConfig: AppConfig = {
    BaiduApi: "https://api.baidu.com",
    AliApi: "https://api.aliyun.com"
}

function injectConfig() {
  
  	// 获取所有 metas
    const metas = document.getElementsByTagName('meta')

    // // 01. 使用 meta 的 id 获取, 与 meta 所在的相对位置有关。
    // const item = metas.item(3)
    // console.log(item);

    // // 02. 使用 meta name 获取
    const item = metas.namedItem('devkit:config')
    // console.log("item=> ", item);

    const content = item?.content
    // console.log("content => ", content);

    if (content) {
        const pairs = content.split(',')
        // console.log("pairs=>", pairs);
        
        for (const pair of pairs) {
            const parts = pair.split('=')
            const key = <keyof AppConfig>parts[0]
            const value = <string>parts[1]

            // 没有 key 或者 没有 value 则跳过
            if (!value || !key) {
                continue
            }

            // 赋值 或 创建
            appConfig[key] = value
        }
    }

    // console.log("appConfig=>", appConfig);
}

// 执行
export default injectConfig()

```



### 3. 在 `main.ts`  中引入

只需要执行， 因此不需要赋值任何变量。 直接 import 导入即可

```ts
// main.ts

// 只需要执行， 因此不需要赋值任何变量。 直接 import 导入即可
import './apis/config'
```



### 4. 在 `vue3` 中使用变量

正常写，` import ts` 文件即可。

```html
<!-- Hello.vue -->

<template>
  <h3>Hello</h3>
  <div>
    <span>AliApi :</span>
    <input type="text" :value="appConfig.AliApi" />
  </div>
</template>

<script setup lang="ts">
import { appConfig } from '@/apis/config'
</script>

<style scoped>
</style>

```



### 5. `envsubst` 通过环境变量注入

1. 假设， 前端代码打包后的 `index.html` 文件名为 `index.html.tmpl`， 启动包含 `${APP_CONFIG}` 占位符， 以便注入 **真实** 的值

```html
<!-- index.html.tmpl -->
<meta name="devkit:config" content="${APP_CONFIG}">
```

2. 使用 `envsubst` 注入环境变量。 这里， 可以使用任何替换的工具和方法。

```bash
## env
# APP_CONFIG=BaiduApi=//Dubai.api.com,QQapi=//QQ.com

envsubst < index.html.tmpl > index.html
```

3. 启动 nginx



## 编外: 通过 `Object.keys` 获取所有字段与字段类型断言



```ts

// 通过 keys 获取 config 所有字段
function initial() {
    // 获取 interface 的 所有 key
    const keys = Object.keys(appConfig)
    console.log(keys)

    // 便利 所有 key
    for (const key of keys) {
        // https://stackoverflow.com/questions/56568423/typescript-no-index-signature-with-a-parameter-of-type-string-was-found-on-ty/56569217
        // key 类型断言
        // const keyname = <keyof AppConfig>key // 方式1
        const keyname = key as keyof AppConfig // 方式2
        console.log("keyname=", keyname);
        console.log("value=", appConfig[keyname]);
    }
}
```

