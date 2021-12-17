---
date: "2016-11-29T00:00:00Z"
description: 使用 python 做网页爬虫
keywords: python
tags:
- python
title: 使用 python 做网页爬虫 目录
---


# 使用python做爬虫

本文是自己在做python爬虫时候的笔记. 目录是从百度文库中找到的, 包含了爬虫基础的方方面面.

各种分类练习代码放在了github上.

本文所有代码就基于 windows 版本的python 2.7.11 x86

## 1. 最基本抓站

对于抓取的对象, 都会使用正则方式进行匹配。 

> 编写正则的一个小技巧： 
>
> 1.将整个resp.read()文本复制下来, 使用删除法进行匹配, 删哪里匹配哪里。
>
> 2. 注意通配符 ` + | * ` 的的贪婪模式， 如果不需要贪婪模式，可以使用 ? 打断。 ` +? | *? ` 
>
> 3. 如果要在多行之间进行匹配, 需要使用标记符号 `patt=re.compile( str, flags=re.MULTILINE + re.DOTALL)`
>



+ [抓取服务器代理](https://github.com/octowhale/program_exercise/blob/master/pyexpamle/py_spider/pyspider_s1_get_proxy.py)
+ [抓取网站图片](https://github.com/octowhale/program_exercise/blob/master/pyexpamle/py_spider/pyspider_s1_download_pics.py)

## 2. 使用代理服务器

### 2.1 第一种代理方式
在windows下时候socket代理的时候, 出现了 `socket.inet_pton` 错误.   
错误原因是 windows下的socket.py 模块没有 `inet_pton` 属性.     
解决方法当然就是 安装 `win_inet_pton` ,  并在 socket.py 中 import.   
具体操作, 参考[Windows下socket inet_pton 错误 ](./python_socket_inet_pton_error.md)

+ [http代理](https://github.com/octowhale/program_exercise/blob/master/pyexpamle/py_spider/pyspider_s2_http_proxy.py)
+ [代理有效性检查 http_proxy](https://github.com/octowhale/program_exercise/blob/master/pyexpamle/py_spider/pyspider_s2_check_proxy.py)

### 2.2 第 2 种代理方式
[使用urllib2.ProxyHandler代理](python_urllib2_opener.md#使用opener支持 http/https/socks5 代理)


## 3. 伪装浏览器

### 3.1 处理表单和cookie
[使用ullib2的opener处理表单和cookie](./python_urllib2_opener.md#使用opener处理表单 和 cookie)

+ [使用Fidder进行嗅探做爬虫签到](http://blog.csdn.net/u283056051/article/details/49946981)
+ [zimuzu.tv 登录签到](https://github.com/octowhale/program_exercise/blob/master/pyexpamle/py_spider/pyspider_s3_zimuzuTV_sign.py)


### 3.2 使用headers伪装浏览器

#### 3.2.1 使用urllib2处理headers
[使用ullib2的opener处理headers信息](./python_urllib2_opener.md#在opener中使用 headers)


#### 3.2.2 使用urllib2.Request处理Headers

```python

headers = {
    'User-Agent': 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.76 Mobile Safari/537.36',
    'X-Forwarded-For': '8.8.8.8',  # 伪装IP地址
    'Accept': 'image/webp,image/*,*/*;q=0.8',
    # 'Accept-Encoding': 'gzip, deflate, sdch',  # 使用后压缩结果
    'Accept-Language': 'zh-CN,zh;q=0.8',
    'Cache-Control': 'max-age=0',
    'Connection': 'keep-alive',
    # 'Content-Type': 'application/html',
}

url_request = urllib2.Request(abs_url, headers=headers)
# content = urllib2.Request(abs_url)
content = urllib2.urlopen(url_request)

```


+ [使用header伪装浏览器](https://github.com/octowhale/program_exercise/blob/master/pyexpamle/py_spider/pyspider_s3_request_headers.py)

### 3.4 反"反盗链"

一些网站反盗链的机制, 说穿了就是查看请求是否来自己的网站。
因此在headers信息中添加`Referer`信息即可。


```


headers={
'Referer':'http://www.cnbeta.com/articles',
}


```


### 3.5 终极绝招

## 4. 多线程并发抓取

## 5. 验证码处理

## 6. gzip/deflate支持

```

headers={'Accept-Encoding':'gzip, deflate, sdch'}

```


+ [header中添加支持压缩](https://github.com/octowhale/program_exercise/blob/master/pyexpamle/py_spider/pyspider_s3_request_headers.py)
+ [解压缩gzip/deflate](https://github.com/octowhale/program_exercise/blob/master/pyexpamle/py_spider/pyspider_s3_extract_respons.py)

## 7. 更方便的多线程
    7.1 用twisted进行异步I/O抓取

## 8. 一些琐碎的经验
    8.1 连接池
    8.2 设定线程的栈大小
    8.3 设置失败自动重连


### 8.4 设置超时

在python2.6以后,可以直接在urllib/urllib2.openurl中设置timeout. 3秒超时` urllib2.urlopen(gg_url,timeout=3)

在python2.6以前,需要通过socket来设置, [参考链接](http://wiki.jikexueyuan.com/project/python-crawler/urllib2-use-details.html)


### 8.5 登陆
登录参考[使用ullib2的opener处理表单和cookie](./python_urllib2_opener.md#使用opener处理表单 和 cookie)

## 9. 总结

[目录结构参考链接](http://wenku.baidu.com/link?url=KGeZwk8lKp6Mor5vkTjrikv1dSjLLhzBmNdHOYCMXGI42LRRKJFWLwB7Sc0LW8OhbBqN88gzOyrLbdGDwu3TDRRNUqZBvmRqpPVA2ox29km)

