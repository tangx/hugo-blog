---
date: "2016-11-09T00:00:00Z"
description: 使用python处理字符串
keywords: python, string, code
tags:
- python
- code
title: python 字符串处理
---

# python 字符串处理

python cookbook 第一章


## 1.1 每次处理一个字符串

### 将字符串转换为列表

使用内建 list ，将字符串转换为列表

```python
theList = list(theString)
```

## 1.7 反转字符串

```python
astring='i have a dream'

# 逐个字符反转
revchars=astring[::-1]

# 按空格拆分为列表并反转
revwards=astring.split()
revwards.reverse()
revwards=' '.join(revwards) # 使用空格链接


# 逐词反转但是改变空格, 使用正则表达式
import re
revwards=re.split(r'(\s+)',astring) # 使用正则表达式拆分保留空格
revwards.reverse()
revwards=''.join(revwards)  # 使用空字符串连接

```

## 1.8 使用set检查字符出现

检查字符串中是否出现了某字符集合中的字符

```python

def containsAny(seq,aset):
    if c in seq:
        if c in aset:
            return True
    return False
    
```

> 注意： 判断存在比判断不存在效率更高，因为不存在会遍历所有字符。

```python

# 使用 itertools 模块

import itertools
def containsAny(seq,aset):
    for item in itertools.ifilter(aset.__contains__,seq):
        return True
    return False
```

> itertools 是标准库模块，比之前的性能更好，但本质上是一样的。

```python
def containsAll(seq,aset):
    '''检查序列seq是否含有aset的所有元素'''
    return not set(aset).difference(seq)
```
> set定义： 任何一个set对象a， a.difference(b) 返回 a 中所有不属于 b 的元素。

## 1.12 字符串大小写

```python
# 大写/小写/单词首字母大写/句子首字母大写
s.upper()
s.lower()
s.title()
s.capitalize()
s.isupper()
s.islower()
s.istitle()
```

## 1.13 访问子字符串

获取字符串的某个部分。

### 切片与 struct.unpack 

```python

# 切片
afield = theline[3:8]

# 使用 struct.unpack 获取一个或多个指定长度的子字符串
import struct

#@breif: 得到第一个5字节的字符串，跳过3字节，得到两个8字节的字符串
baseformat = "5s 3x 8s 8s"


#@breif: 得到之前剩余部分字符串
numremain=len(theline)-struct.calcsize(baseformat)
format="%s %ds" % (baseformat,numremain)

# 注意：struct.calcsize(baseformat) 计算格式化字符串的长度

# 获取截取的字符串
l,s1,s2,t=struct.unpack(format,theline)

# 如果想要跳过其余部分，需要截取theline开头部分
l,s1,s3=struct.unpack(baseformat,theline[:struct.calcsize(baseformat))

```
> 注意： `l,s1,s2=struct.unpack(baseformat,theline)` 
> len(theline) 必须与 struct.calcsize(format) 相等，不然会报错。

### 带列表推倒(LC)的切片

```python

# 获取 5 个字节一组的数据
fivers=[theline[k:k+5] for k in xrange(0,len(theline),5)]

# 一个字节
chars=list(theline)

# 使用LC获取指定长度的切片边界
cuts=[8,14,20,26,30]
pieces=[theline[i:j] for i,j in zip([0]+cuts,cuts+[None])]
>>> for x in zip([0]+cuts,cuts+[None]):
	print x
(0, 8)
(8, 14)
(14, 20)
(20, 26)
(26, 30)
(30, None)
```

LC中调用zip，返回一个列表，形如`([cuts[k],cuts[k+1])`。


## 1.24 让某些字符串大小写不敏感

