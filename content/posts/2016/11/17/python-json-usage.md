---
date: "2016-11-17T00:00:00Z"
description: 使用 python 解析 json 字符串，以及字典与 json 的差异
keywords: python, 解析, 参数
tags:
- python
- library
title: python 字典与 json 异同
---


# json 与 dict

从结构上来看， json 字符出与 python 字典看起来很相似，都是大括号 `{}` 括起来的键值对 `{key:value}`。

` s='{"number":10,"map":"china","10":"the number"}' ` 该字符串可以通过**字符串转字典 `eval(s)` **也可以通过**json转字典 `json.loads(s)` **方式转换成字典  

```
s='{"number":10,"map":"china","10":"the number"}'

s_d=eval(s)
print s_d
# {'map': 'china', 'number': 10, '10': 'the number'}


import json

s_j=json.loads(s)
print s_j
# {u'map': u'china', u'number': 10, u'10': u'the number'}

s_d	is s_j
# False

s_d	== s_j
# True

print type(s_d)
# <type 'dict'>
```

然而差别在于：

+ 引号差异： json 中，如果 key 和 value 是字符串，则必须使用双引号； 而 python 字典中，可以是单引号或双引号。
+ key 差异： json 中， key 只能是字符串； 而 python 字典中， key 可以是字符串或数字。
+ value 差异（关键字）： json 中，使用的关键字使用的是小写字符 `(ex, false, true, null)`；而 python 的关键是为 `( True, False, None )`

共同之处在于：

字典支持的 value 类型， json不一定都支持。 但是 json 和 dict 对 value 的类型有:

+ 字符串 string
+ 数字 number
+ 字典 dict
+ 列表 list


```
#!/usr/bin/env python
# encoding: utf-8

"""
@version: 01
@author: 
@license: Apache Licence 
@python_version: python_x86 2.7.11
@site: octowahle@github
@software: PyCharm Community Edition
@file: python_json.py
@time: 2016/11/16 13:58
"""

import json

def get_json_elements(s):
    data = json.loads(s)

    # print data
    print type(data)

    print data['data']['attributes']['created_at']
    print data['data']['attributes']['envs']
    print data['data']['attributes']['is_running']

if __name__ == '__main__':
    json_string = '''{"data":{"type":"containers","attributes":{"app_id":"3249dfce-513a-4fb7-82fc-978fa4581d19","image_name":"uyinn28/centos6:ss-0.0.1","is_running":false,"instances":1,"mem":256,"envs":null,"ports":[{"number":14343,"protocol":"tcp"}],"created_at":"2016-10-29T17:47:59.535+09:00","custom_domains":null},"relationships":{}}}'''
    get_json_elements(json_string)

# <type 'dict'>
# 2016-10-29T17:47:59.535+09:00
# None
# False
# None
```

![json.png](/assets/img/post/2016/2016-11-17-python-json-usage-01.png)

从上面代码中的结果与图片对应部分我们可以看到

+ 通过命令 ` json.loads(s) ` 将 json 字符串转换成了字典。
+ 关键字如 ` null , false ` 也转换成了对应字典的关键字 ` None, False `
+ 取值方式就是字典操作。

