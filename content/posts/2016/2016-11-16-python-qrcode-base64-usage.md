---
date: "2016-11-16T00:00:00Z"
description: 使用python对字符串进行base64编码和解码，以及生成字符串的二维码
keywords: python, qrcode, encrypt
tags:
- python
- code
- library
title: 使用python生成base64编码和qrcode二维码
---

# 使用python对字符串进行base64编码以及生成字符串qrcode二维码

最近将ss服务器搬到免费docker上面去了。由于是免费的，每次容器重启的时候都会重新绑定服务器地址和容器端口。然而作为一个懒鬼，并不想每次都手动复制粘贴这些信息，于是新需求就是docker容器服务绑定完成后，自己获取服务信息并编码，并通过邮件发送。

随后的代码是字符串base64编码和生成二维码部分。

其中有一些注意事项

## base64编码与解码

+ 使用 ` base64.b64encode(s) ` 对字符串进行编码
  + 编码后，不需要手动去除编码后的占位符 ` = `。
  + 有需求的话，可以去除字符串左右的空格 `( s.strip() )`
+ 使用 ` base64.b64decode(s) ` 对编码后的字符串进行解码
  + 如果之前清除了编码后的占位符，解码会失败

## 生成二维码 qrcode

生成二维码时需要用到两个库

+ qrcode 
  + 生成二维码的代码库
+ Image 
  + Image 库不需要手动导入，生成图片生会自己调用

## 代码片段
```python
#!/usr/bin/env python
# encoding: utf-8

"""
@version: 01
@author: 
@license: Apache Licence 
@python_version: python_x86 2.7.11
@site: octowahle@github
@software: PyCharm Community Edition
@file: python_arukas_api.py
@time: 2016/11/14 12:18
"""

"""
pip install qrcode
pip install Image
"""

# import os, sys
import base64
import qrcode
# 生成二维码还需要 Image 库
# import Image # 但此处不需要导入


def get_base64_encode(s):
    '''
        对字符串执行base64编码和解码
    '''

    # 编码
    # 不需要手动去除最后面的（占位符）等号，否则解码会出错
    # s_base64 = base64.b64encode(s).rstrip('=')  # 这是错的

    s_base64 = base64.b64encode(s)

    # 解码
    # s= base64.b64decode(s_encode)

    return s_base64


def gen_qrcode(s, image_name="pictname.png"):
    '''
        将字符串生成二维码
    '''

    # 创建对象,所有参数都有默认值。
    # qr=qrcode.QRCode()
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=5,
        border=4,
    )

    # 为对象添加数据
    qr.add_data(s)

    # 生成适应大小的图片
    qr.make(fit=True)  # 可以省略

    # 创建图片对象并保存
    img = qr.make_image()
    img.save(image_name)


if __name__ == "__main__":
    s = "i have a dream"
    s_encode = get_base64_encode(s)
    gen_qrcode(s)


```
