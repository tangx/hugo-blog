---
date: "2021-08-26T00:00:00Z"
description: typescript 中的 const 断言
keywords: typescript, const
tags:
- typescript
title: typescript 中的 const 断言
---

# typescript 中的 const assertions

> [const assertions - TypeScript 3.4](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-4.html#const-assertions)

```ts
// vue3

const dnsProviders = {
    "aliyun.com": "alidns",
    "tencent.com": "dnspod"
}

let data = reactive({
    rootDomain: "aliyun.com" as const
})

let dnsProvider = computed(
    () => {
        return dnsProviders[data.rootDomain]
    }
)
```

![7053-error.png](/assets/img/post/2021/08/26/typescript-const-assertions/7053-error.png)

这个时候会， 提示  7053 错误， `data.rootDomain` 具有 `any type`, 不能被用作 key。

解决这个问题使用， 需要使用 typescript 中 `const assertion` 类型推断。

### `const assertion` 类型推断。

1. **字面量类型推断**: 其类型为字面值类型。
   1. 例如这里的 `hello` 的类型是 `hello` 不是 `string`
   2. `n` 的类型是 `1` 不是 `number`

```ts
let x = "hello" as const  // type "hello"
let n = 1 as const  // type 1
```

2. **object** 得到的是一个**只读属性**

```ts
let z = { text: "hello" } as const;  // // Type '{ readonly text: "hello" }'
```

3. **数组 array** 得到一个 **只读元组 （tuple）**

```ts
let y = [10, 20] as const; // Type 'readonly [10, 20]'
```



### 注意事项

1. `const` 推断只能用于 **简单字面表达式**， 即 `string, number, boolean, array, object` 

```ts
// 错误! 
let a = (Math.random() < 0.5 ? 0 : 1) as const;
let b = (60 * 60 * 1000) as const;

// 可行!
let c = Math.random() < 0.5 ? (0 as const) : (1 as const);
let d = 3_600_000 as const;
```



2. `const` 上下文执行的时候， 并不会**立即**将 **一个可变表达式** 转换成 **完全不可变的** 状态（readonly）
   1. foo 的属性不能进行完全替换
   2. 但是 foo 的属性 content 的值是 arr 依旧可以进行数据操作， 没有成为 readonly

```ts
let arr = [1, 2, 3, 4];
let foo = {
  name: "foo",
  contents: arr,
} as const;

// foo 的属性不能进行完全替换
foo.name = "bar"; // error!
foo.contents = []; // error!

// 但是 foo 的属性 content 的值是 arr 依旧可以进行数据操作， 没有成为 readonly
foo.contents.push(5); // ...works!
```

