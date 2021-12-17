---
date: "2021-09-01T00:00:00Z"
description: typescript 中使用 @ 路径别名
keywords: typescript
tags:
- typescript
title: typescript 中使用 @ 路径别名
---

# typescript 中使用 @ 路径别名



使用路径别名  `@/some/path/index.ts`  可以很简单的表示一个文件的绝对路径（其实是相对于 `@` 的相对路径）

1. 安装 `@types/node`

```bash
yarn add @types/node
```

2. 配置 `tsconfig.json` , 一下是基于 `vite2` 项目配置 

```json
{
    "compilerOptions": {
        // ... ,
        "types": [
            "node"
        ],
        // https://github.com/vitejs/vite/issues/279
        "paths": {
            "@/*": [
                "./src/*",
            ]
        }
    },
    // ...
}
```



3. 就可以在 `ts` 文件中使用 `@` 别名引入了。

```ts
// 使用绝对路径
import httpc from '@/apis/httpc'
// 使用相对路径
import httpcli from './httpc'

export interface DomainRelation {
    domain: string
    provider: string
}

async function getDomains(): Promise<DomainRelation[]> {
    const resp = await httpc.get('/domain')
    return resp.data
}

export default {
    getDomains
}
```

