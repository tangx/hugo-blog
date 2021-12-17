---
date: "2016-11-09T00:00:00Z"
description: 在python中使用指定可选参数功能。增强程序适用性
keywords: python, code
tags:
- python
- library
- code
title: python 中使用参数选项 getopt
---

# python 中使用 getopt 分割参数

getopt 库是 python 内建库，以使用 getopt 库为程序指定可选参数。

```python
# @python_version: python_x86 2.7.11

import getopt

```

## 指定选择项 opts 使用的长短字符

参数选择项通常有长短两种：

+ 长短选择项本身都为字符串
+ 短选择项的符号必须单字母，如果需要使用参数，选择项符号后需要使用 `:`（如 `'o:'`。所有短选择项构成一个**字符串**传递给 `getopt` 。
+ 长选择项的符号通常使用单词或短语，如果需要使用参数，选择项符号后需要使用 `=`（如 `'output='` ）。所有长选择项构成一个列表。

```python
try:
    opts, args = getopt.getopt(sys.argv[1:], 'ho:', ['help', 'output='])
except getopt.GetoptError, err:
    print err

```

+ 传递所有参数 ` sys.argv[1:] ` 到 `getopt.getopt`。
+ 指定短参数符号 `ho:` ，其中 `-h` 不使用参数， `-o ` 必须指定参数。
+ 指定长参数符号 `['help', 'output=']` ，其中 `--help` 不使用参数，`--output` 必须指定参数。
+ 将参数分解完毕后，分别传递给 `opts` 和 `args`。

> ` getopt.GetoptError ` 为抓取的错误信息


## 选择项 opts 和参数 args

使用 getopt 整理传参后，会得到连个列表： opts 和 args。
+ opts 列表中的元素以元组的方式成对出现，分别对应选择项及其值 ` ('opt','arg') ` 。如果 opt 是无参数选择项，则对应的 arg 为空 `('opt','')` 。
+ 传递多个参数，必须使用列表。

```python
import sys
import optget

def switch(argvs):
    try:
        opts, args = getopt.getopt(argvs, 'ho:', ['help', 'output='])

        print 'opts的值为：',
        print opts
        print 'args的值为：',
        print args
        
    except getopt.GetoptError, err:
        print err


if __name__ == '__main__':
    argvs = ['-h', '-o', 'filename1', '--help', '--output', 'filename2', 'arg1', 'arg2']
    switch(argvs)
    # switch(sys.argv[1:])

```

> 注意 ` switch(sys.argv[1:]) ` 这里是使用系统传参。 `sys.argv[0]` 是程序文件本身，所以过滤。

可以看到，输出结果为：

```
opts的值为： [('-h', ''), ('-o', 'filename1'), ('--help', ''), ('--output', 'filename2')]
args的值为： ['arg1', 'arg2']
```

## 解析 opts 的值

在获取到 `opts` 之后， 我们可以使用循环获取选项，并判断其是否出现。

```python

import sys
import os
import getopt


def switch(argvs):
    try:
        opts, args = getopt.getopt(argvs, 'ho:', ['help', 'output='])

        for o, a in opts:
            # @ o for opt
            # @ a for arg
            print ' %s -> %s  ' % (o, a)
            if o in ('-h', '--help'):
                print "这里全部都是帮助信息"
            if o in ('-o', '--output'):
                print "新的输出文件名为 %s" % a
    except getopt.GetoptError, err:
        print err


if __name__ == '__main__':
    argvs = ['-h', '-o', 'filename1', '--help', '--output', 'filename2', 'arg1', 'arg2']
    switch(argvs)

```


```
 -h ->   
这里全部都是帮助信息
 -o -> filename1  
新的输出文件名为 filename1
 --help ->   
这里全部都是帮助信息
 --output -> filename2  
新的输出文件名为 filename2
```

[ 库文件信息 ](http://python.usyiyi.cn/translate/python_278/library/getopt.html)



