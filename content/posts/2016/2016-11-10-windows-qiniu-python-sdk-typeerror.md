---
date: "2016-11-10T00:00:00Z"
description: 'windows下调用qiniu-python-sdk上传文件时报错：TypeError: unsupported operand type(s)
  for +: ''NoneType'' and ''str'''
keywords: python, qiniu, sdk
tags:
- python
- code
- qiniu
title: windows 下 qiniu-python-sdk 错误及解决方法
---

# 报错信息

```
  File "E:\Python27\lib\site-packages\qiniu\zone.py", line 131, in host_cache_file_path
    return home + "/.qiniu_pythonsdk_hostscache.json"
TypeError: unsupported operand type(s) for +: 'NoneType' and 'str'
```

# 解决方法

```
    def host_cache_file_path(self):
        home = os.getenv("HOME")

        # @ 增加 None 值判断
        # @ 如果 home 值为 None， 则使用当前路径
        if home is None:
            # home=os.path.join('.'+'C:\Users\Public')
            home=os.curdir

        # @ 修改路径链接方式
        return os.path.join(home,"/.qiniu_pythonsdk_hostscache.json")
        # return home + "/.qiniu_pythonsdk_hostscache.json"


```

> 出现问题后，使用当前目录 ` os.curdir ` 的值通常为运行的 python 文件的根目录（ 如： ` C: , E: `）


# 问题出现原因

zone.py 预计使用环境为 linux 
+ windows 下， python 不能正确获取用户家目录，导致返回值为 ` None `。
+ windows 和 linux 路径格式不一致， 而 `host_cache_file_path` 的返回值默认为**字符串连接**` string + string ` 而导致类型错误。