---
date: "2021-09-28T00:00:00Z"
description: vue3 使用 @ 路径别名
featuredImagePreview: topic/vue.png
keywords: vue3
tags:
- cate1
- cate2
title: vue3 使用 @ 路径别名
typora-root-url: ../../
---


# 使用 `@` 路径别名

在使用 `import`  的时候， 可以使用相对路径 `../components/HelloWorld.vue` 指定文件位置， 但这依赖文件本身的位置，在 **跨目录** 的时候， 并不方便。

例如， **路由文件** 要使用 **Components 组件**

```ts
// file: /src/router/index.ts
// 路由目标组件
import HelloWorld from '../components/HelloWorld.vue'
import World from '../components/World.vue'
```

要使用路径别名， 需要进行一些额外配置

## 安装 `@types/node` 支持

安装 `@types/node` 组件

```bash
yarn add @types/node
```

在 `tsconfig.json` 中， `compilerOptions` 下配置

```ts
{
  	// ... ,
    "compilerOptions": {
      // ....
        "types": [
            "node"
        ]
    }
}
```

## `vite.cofnig.ts` 配置

```ts
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// 需要引入 path 模块
// yarn add @types/node
import path from "path";

// https://vitejs.dev/config/
export default defineConfig({
  	// resolv 对象中配置
    resolve: {
      	// 别名配置
        alias: {
          	// @ => src
            "@": path.resolve(__dirname, "src"),
          	// @comps => "src/components"
            "@comps": path.resolve(__dirname, "src/components"),
            "@router": path.resolve(__dirname, "src/router"),
            "@utils": path.resolve(__dirname, "src/utils")
        }
    },
    plugins: [
        vue()
    ]
})

```

使用路径别名之后， 就可以使用 **简短** 的 **绝对路径** ， 不仅指向 **更清晰** ，而且还不在依赖当前文件的位置。

```ts
// file: /src/router/index.ts
// 路由目标组件
import HelloWorld from '@/components/HelloWorld.vue'
import World from '@/comps/World.vue'
```

