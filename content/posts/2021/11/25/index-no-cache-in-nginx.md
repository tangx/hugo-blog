---
date: "2021-11-25T00:00:00Z"
description: nginx 实现首页不缓存
featuredImagePreview: /assets/topic/pandalisa.png
keywords: cdn, nginx, cache
tags:
- cdn
- vue3
- nginx
title: nginx 实现首页不缓存
typora-root-url: ../../
---

# nginx 实现首页不缓存 

前端上 CDN 加速， 后端上 DCDN， 加速网站访问速度。

前端代码编译的时候， 可以加上 hash 值使编译后的产物名字随机， 可以在不刷新 CDN 资源 的情况下， 保障页面展示最新。 虽然对多了一点回源， 但减少了人工操作。

但是 **首页不能被缓存**， 否则于事无补。

对于首页的缓存设置， 有一点注意事项， 

**其一** ， 带 `/index.html` 的首页， 如

```bash
http://www.baidu.com/index.html
```

可以直接在云上 CDN 上直接配置， 因为这种可以被定义为 **单文件** 资源。



**其二**， 带 `/` 就比较麻烦了，`/index.html` 是默认页面， 可以直接展示。 

```bash
http://www.baidu.com/
```

但在 CDN 缓存规则上可能各个云上的定义不一致。



为了屏蔽这种问题， 最好的方式就是在 **源站** 上就通过 Header `Cache-Control` 控制缓存， 所有 CDN 依照源站规则即可。

对于不需要缓存的资源， 在响应头中使用  `Cache-Control: no-cache` 即可。

nginx 配置如下。

```properties
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;

    # 不缓存  /  与  /index.html
        if ($request_uri ~* "^/$|^/index.html") {
            add_header    Cache-Control no-cache ;
        }
    }
}

```



## Cache-Control

1. 设置相对过期时间, max-age指明以秒为单位的缓存时间. 

2. 若对静态资源只缓存一次, 可以设置max-age的值为315360000000 (一万年). 
3. 比如对于提交的订单，为了防止浏览器回退重新提交，可以使用Cache-Control之no-store绝对禁止缓存，即便浏览器回退依然请求的是服务器，进而判断订单的状态给出相应的提示信息！

**Http协议的cache-control的常见取值及其组合释义:**

`no-cache`: 数据内容不能被缓存, 每次请求都重新访问服务器, 若有max-age, 则缓存期间不访问服务器.
`no-store`: 不仅不能缓存, 连暂存也不可以(即: 临时文件夹中不能暂存该资源).
`private`(默认): 只能在浏览器中缓存, 只有在第一次请求的时候才访问服务器, 若有max-age, 则缓存期间不访问服务器.
`public`: 可以被任何缓存区缓存, 如: 浏览器、服务器、代理服务器等.
`max-age`: 相对过期时间, 即以秒为单位的缓存时间.
`no-cache, private`: 打开新窗口时候重新访问服务器, 若设置max-age, 则缓存期间不访问服务器.
  \- `private`, 正数的max-age: 后退时候不会访问服务器.
  \- `no-cache`, 正数的max-age: 后退时会访问服务器.

