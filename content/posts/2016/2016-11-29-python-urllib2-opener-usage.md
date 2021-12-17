---
date: "2016-11-29T00:00:00Z"
description: 在 python 中使用 opener 进行网页访问
keywords: python
tags:
- python
title: 在 python 中使用 opener 进行网页访问
---

# 在 python 中使用 opener 进行网页访问

在网页访问中,  urllib2 提供了很多 handler,  并且默认支持 http 访问的。因此, 我们可以使用 http handler 初始化一个 opener。 
其他的所支持的模式,  我们可以通过  `opener.add_handler(handler)` 添加。 

```python
# function get_opener()     # 后面案例需要调用这个方法
import urllib2
url_abs='http://ip.cn'
opener=urllib2.build_opener(urllib2.HTTPHandler())
resp=opener.open(url_abs)
return opener

```

## 使用opener处理表单 和 cookie

如果遇到需要登录的网站,  可能就需要使用到 `表单` 和 `cookie`。
因为 urllib2 中没有 `urlencode(dict)` 方法, 因此在处理表单的时候, 需要引入 `urllib` 模块。
如果启用了cookie,  那么在只用表单登录之后,  访问其他网页时就不需要在传入表单数据 (如果网站支持的话)。

```python
import urllib
import cookielib
opener=get_opener()         # 获取opener

# 添加 cookie 支持
cj=cookielib.CookieJar()
cookie_support=urllib2.HTTPCookieProcessor(cj)
opener.add_handler(cookie_support)
# 处理表单
user_info={
    'username':username,
    'password':password,
    }
user_info_encode=urllib.urlencode(user_info)
# 使用表单登录
resp=opener.open(http_url,data=user_info_encode)
# 使用cookie访问其他网页
resp=opener.open(http_other_url)       # 默认使用 GET() 方法请求
resp=opener.open(http_other_url,data='')       # 使用 POST() 方法请求

```

在opener.open(url,data)使用了data参数后, 访问方法由默认的 `GET` 变为 `POST`。
如果在访问网站时,  需求方法为 POST 但是不提交任何数据,  那么可以为data使用一个空字符串达到效果( `data=''` )。

## 使用opener支持 https

```python

opener=get_opener()
https_url='https://www.baidu.com'
https_support=urllib2.HTTPSHandler()
opener.add_handler(https_support)
resp=opener.open(https_url)

```

## 在opener中使用 headers

为opener添加headers支持与添加一般的handler不一样 ,  命令为 `opener.addheaders = header_list`。
需要注意的是,  通常情况下我们编写headers信息是使用字典结构(dict)。 
但是在为 opener添加headers支持的时候,  需要使用列表结构(list), 主要是为了方便添加更多的headers键值对。 
且其中的键值对需要使用`元组结构(tuple)`。 
`[(key,value),(key,value)]`


```python

opener=get_opener()
headers = {
    'User-Agent': 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.76 Mobile Safari/537.36',
    # 'X-Forwarded-For': '171.212.113.133',  # 伪装IP地址
    'Accept': 'image/webp,image/*,*/*;q=0.8',
    # 'Accept-Encoding': 'gzip, deflate, sdch',  # 使用后压缩结果
    'Accept-Language': 'zh-CN,zh;q=0.8',
    'Cache-Control': 'max-age=0',
    'Connection': 'keep-alive',
    # 'Content-Type': 'application/html',
}
header_list = []
for key, value in headers.items():
    header_list.append((key, value))
opener.addheaders = header_list
return opener

```

## 使用opener支持 http/https/socks5 代理

urllib2提供了代理支持, 添加代理支持的命令为  `opener.add_handler=urllib2.ProxyHandler({type:host_port})`。 
其中 type的值可以是 `http|https|socks5` , host_port的值为 `host:port`。

```python

opener = get_opener()
#
proxy_type='socks5'
proxy_host_port='127.0.0.1:1080'
proxy_support=urllib2.ProxyHandler({proxy_type:proxy_host_port})
opener.add_handler(proxy_support)
print opener.open('http://ip.cn/').read()

```

