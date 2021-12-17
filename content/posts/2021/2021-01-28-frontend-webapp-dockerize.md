---
date: "2021-01-28T00:00:00Z"
description: 在容器启动的时候，将环境信息初始化到静态文件中，实现无状态镜像。
keywords: docker, js
tags:
- docker
title: 静态前端网站容器化
---

# 静态前端网站容器化

在容器启动的时候，将环境信息初始化到静态文件中，实现无状态镜像。

## 现实与需求

1. `js` 代码需要先从服务器下载到**客户本地浏览器运行**， 再与后端的服务器进行交付提供服务。
2. 使用 nodejs 书写的网站， 通过 **编译** 产生静态文件， 放在 **WEB容器** (例如 nginx/caddy ) 中即可对外提供服务。
3. 容器本身需要无状态， 实现一处编译， 处处运行。

## 困境与曙光

那么问题来了， **变量** 信息已经在编译的时候就写入了 `index.html, xxx.js` 等静态文件中。 随后在客户本地浏览器中解释运行， 并不能像后端服务一样，方便的读取服务器中的环境信息。
那么要如何实现在运行时获取服务器中提供的 **特定环境相关信息** 呢？

1. 虽然， 可以本地运行 `js` 到一个固定的地址下载相关环境的信息， 在本地解析后访问访问信息地址。
    + 这样就需要一个 **中心化** 的维护状态的服务。 对于项目制的试试产品而言缺少可移植性。
2. 但是， 可以通过 **WEB容器** 的将 **环境信息** 初始化到静态文件中。


## 实现与案例

这里所说的 **WEB容器** 可以是 `nginx / caddy` 这样公共开源的。 也可以是各自公司自行开发的。

前面说了， 为了实现**无状态镜像** ， 需要以下几个关键点

1. **可变/可注入** 的环境信息
2. **可执行初始化** 操作的 WEB 容器。

> 初始化的核心思想: 替换

说这么多， 其实初始化最简单的方式就是 **替换** 。 即

> 在 nodejs 编译使用的配置文件中， 使用 **变量占位符** 进行编译， 生成静态文件。 并在容器启动的时候，通过**某种方式**替换为环境变量中真实的值。 

某种方式可以是 **WEB容器程序** 本身的功能模块， 也可以是定制的容器镜像的初始化 `entrypoint.sh` 

这里， nginx 静态网站为例

1. 假如 `index.html` 为编译的静态结果
2. 定义了三个变量，分别为 `USER, SERVER_API, CDN_URL`
3. 为了方便定位替换， 占位符前缀为 `__App_`
4. 使用固定的 `APP_CONFIG` 变量名注入信息。 为了注入多变量额外使用了 `;` 分号进行变量分割
5. nginx 本身不具备初始化功能， 且修改源码再编译成本和易用性不高。 因此使用了 `entrypoint.sh` 进行启动前初始化。



**index.html**

```html
<h1>Welcome: __App_USER</h1>

<br>
__App_SERVER_API/user/info
<br>
__App_CDN_URL/xxx/1.png
```


**Dockerfile**

```Dockerfile
FROM nginx:alpine

RUN apk add bash --no-cache
ADD entrypoint.sh /entrypoint.sh
ADD dist /usr/share/nginx/html
ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]


```

**entrypoint.sh**

```bash
#!/bin/bash

## 初始化环境变量
# export APP_CONFIG="__App_CDN_URL=https://cdn.example.com;__App_SERVER_API=https://api.example.com;__App_USER=User1"
for val in $(echo $APP_CONFIG | sed 's/;/ /g')
do
{
    ## <<< 赋值需要 bash 支持
    read key value <<< $(echo $val | sed 's/=/ /')

    ## 初始化变量
    sed -i "s@$key@$value@" /usr/share/nginx/html/index.html
}
done

## 启动 nginx
exec nginx -g "daemon off;"
```

**docker-compose.yml**

使用 docker-compose 运行容器， 并注入环境变量

```yaml
version: '3.1'

services:
  web1:
    image: cr.example.com/webappserve:latest
    build: .
    ports:
      - 40080:80
    environment:
      APP_CONFIG: __App_CDN_URL=https://cdn.example.com;__App_SERVER_API=https://api.example.com;__App_USER=user1"
  web2:
    image: cr.example.com/webappserve:latest
    build: .
    ports:
      - 30080:80
    environment:
      APP_CONFIG: __App_CDN_URL=https://cdn.EXAMPLE.COM;__App_SERVER_API=https://api.EXAMPLE.COM;__App_USER=user2
```

执行结果如下

![frontend-dockernize.png](/assets/img/post/2021/01/28/frontend-dockernize.png)

