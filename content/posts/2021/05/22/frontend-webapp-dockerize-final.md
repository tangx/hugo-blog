---
date: "2021-05-22T00:00:00Z"
description: 前端网站实现容器化的一个核心要点， 就是 html5 中的 meta。 js script 通过自定义 meta 字段拿到环境变量
keywords: js, html5, docker, dockerize
tags:
- js
- html5
title: 使用js读取html meta 实现静态前端网站容器化
---

# 使用js读取html meta 实现静态前端网站容器化


之前写过一篇关于前端容器化的文章， [静态前端网站容器化](http://www.sodev.cc/2021/01/28/frontend-webapp-dockerize/)。 现在看来， 那个方案的可操作性并不高， 而且很弱智。 
其中实现是需要使用 `sed` 替换 **所有文件** 中的占位符。

然后， js 本身是可以通过 html meta 传递信息的。

以下， 则是 **通过 js 获取 html meta 信息以实现前端容器化**

## 1. 重新整理一下需求

1. 前端 nodejs 的代码需要编译打包并构建容器镜像
2. 满足容器 **一次打包四处运行** 是最基本的需求。
3. 因此需要通过 **环境变量** 提供实际运行环境的变量值。
4. 使用 **关键字 `html5 meta`** 提供变量真实值。
5. 使用 **js** 获取 **meta** 信息， 赋值预定义变量。


## 2. 案例

这里还是以 `nginx:alpine` 作为 web 容器作为案例讲解。

### 2.1. index.html 要怎么写

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- 1. 使用 meta 定义环境变量 -->
    <meta name="devkit:config" content="${APP_CONFIG}">
    <!-- 
        假如 APP_CONFIG 字段格式为 APP_CONFIG=KEY1=value1,KEY2=value2
            每组kv 内部 使用 = 等号 链接: key1=value1
            多组kv 之间 使用 , 逗号 联结: KEY1=value1,KEY2=value2
        
        最终渲染结果如下
        <meta name="devkit:config" content="APP_CONFIG=API_SERVEER=http://exmaple.com,REMOTE_SERVER=http://example.cn">
    -->


    <script>
        // 2. 通过 js 获取 meta 信息
        var metas = document.getElementsByTagName('meta');
        for (var i = 0; i < metas.length; i++) {
            // 如果 meta 是我们定义的
            if (metas[i].getAttribute('name') === 'devkit:config') {
                // 获取 meta 对应的 content 值
                var content = metas[i].getAttribute('content');
                var kvs = content.split(',');
                for (var j = 0; j < kvs.length; j++) {
                    if (kvs[j]) {
                        var values = kvs[j].split('=');
                        // 赋值
                        if (values.length > 1 && values[0] === 'API_SERVEER') {
                            window.___url = values[1];
                            break;
                        }
                    }
                }
            }
        }

    </script>
    <title>Document</title>
</head>
<body>
    <!-- 真实内容 -->
</body>
</html>
```


1. 约定一个 meta 提供环境变量 `<meta name="devkit:config" content="${APP_CONFIG}">`
2. 研发代码使用 js 获取 meta `var metas = document.getElementsByTagName('meta');`
3. 使用 `envsubst` 渲染真实值替换 `${APP_CONFIG}` 占位符。 不了解 `envsubst` 命令的可以自行百度。
    + `envsubst < index.html.tmpl > index.html` 。 


### 2.2. 变量渲染值要怎么约定

细心的你可以能已经发现， 上面提供的 `index.html` 在编译的时候会报错。
因为 `${APP_CONFIG}` 这种 **shell** 环境变量的写法， 在 **js** 中也是相同语意的。
因此造成了 `${APP_CONFIG}` 作用域的冲突。

为了解决这个问题， 我们需要和确认 **由谁来生成 `${APP_CONFIG}`** 这个占位符。

#### 2.2.1. 由运维解决

1. 在 template 模版中， 使用 `APP_CONFIG` 作为占位符, meta 行如下

```html
<meta name="devkit:config" content="APP_CONFIG">
``` 

2. `docker-entrypoint.sh`

```bash
#!/bin/sh
# vim:sw=4:ts=4:et

set -e

cd /usr/share/nginx/html

### 1. 替换占位符: APP_CONFIG 为 ${APP_CONFIG}
sed -i '/devkit:config/s/APP_CONFIG/${APP_CONFIG}/' index.html.tmpl
### 2. 渲染占位符:
envsubst < index.html > index.html.tmp
### 3. 覆盖 index.html
mv index.html.tmp index.html


exec "$@"
```

3. 运行容器 **nginx:alpine** `Dockerfile`

```Dockerfile
FROM nginx:alpine

WORKDIR /usr/share/nginx/html

ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

# docker build -t example.com/runtime/webappserve:nginx .
```


#### 2.2.2. 由研发解决

1. 假如前端打包一般使用 `webpack`, 要求 `webpack` 的版本大约 4.0。
  在 `webpack` 配置变量渲染配置如下

```js
    // ...
    plugins: [
        new CleanWebpackPlugin(), // 清除编译目录
        // 主页面入口index.html
        new HtmlWebpackPlugin({
            filename: 'index.html',
            template: './index.html.tmpl',
            favicon: './src/images/favicon.ico',
            templateParameters: { APP_CONFIG: '${APP_CONFIG}' }
        }),
    // ...
```

2. 在 template 模版中， 需要对应修改 `APP_CONFIG` 占位符的值为 `<%= APP_CONFIG %>` ， 如下

```html
    <!-- 最终编译后的 index.html 文件， 必须包含如下 meta 信息
        <meta name="devkit:config" content="${APP_CONFIG}">

        因此，在 webpack 阶段，
        // https://stackoverflow.com/questions/45223299/unable-to-inject-data-into-template-with-html-webpack-plugin
        需要使用 `<%= APP_CONFIG %>` 作为占位符， 才能渲染成功得到最终结果。
    -->
    <meta name="devkit:config" content="<%= APP_CONFIG %>">

```

### 2.3. 变量个数和规则要怎么约定

1. 以上案例中， 只使用了 `APP_CONFIG` 一个占位符传递环境变量。 而多个环境变量之间使用 `APP_CONFIG=k=v,k2=v2` 的方式组合字符串进行传递。至于到底 **是否需要开发多个占位符** 这个问题。 我建议是 **尽可能的少** ， 因为 shell 和 js 的变量含义有冲突， 尽量少的使用才可能降低异常概率。
