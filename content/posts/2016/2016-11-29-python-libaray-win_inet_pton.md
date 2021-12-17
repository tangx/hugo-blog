---
date: "2016-11-29T00:00:00Z"
description: windows 下为 python 安装 win_inet_pton 错误解决方法
keywords: python
tags:
- python
title: windows 下为 python 安装 win_inet_pton
---

# windows 下为 python 安装 win_inet_pton
 
AttributeError: 'module' object has no attribute 'inet_pton'

我在windows下使用的是python 2.7.11; 自带的socket是不包含inet_pton方法的. 

因此, 在做socket代理的时候, socket调用 `inet_pton`方法会报错, 提示 `AttributeError: 'module' object has no attribute 'inet_pton'` .


## windows 使用 socket 报错: 


```

  File "E:Python27libsite-packagessocks.py", line 482, in _SOCKS5_request
    resolved = self._write_SOCKS5_address(dst, writer)
  File "E:Python27libsite-packagessocks.py", line 517, in _write_SOCKS5_address
    addr_bytes = socket.inet_pton(family, host)
AttributeError: 'module' object has no attribute 'inet_pton'

```


## 解决方法:
1. 安装 `win_inet_pton`,

```

pip installl `win_inet_pton`

```

2. 在socket中添加导入`win_inet_pton`的代码(`import win_inet_pton`)


```python

# # # # # 2016.08.01 # # # # # # # #
try:
    if os.name == 'nt':
        import win_inet_pton
except ImportError:
    # win_inet_pton import error
    pass
# # # # # # # # # # # # # # # # # # # #

```


## 参考链接

https://pypi.python.org/pypi/win_inet_pton
https://github.com/mitsuhiko/python-geoip/issues/4
http://www.panweizeng.com/python-urllib2-socks-proxy.html

