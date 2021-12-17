---
date: "2016-11-29T00:00:00Z"
description: 在 shell 中使用后台运行模拟多线程处理
keywords: shell, 多线程
tags:
- shell
title: shell 模拟多线程处理
---

# shell 模拟多线程处理

shell并发的本质就是**将代码块放入后台运行**
并发数量控制的本质是**通过读取管道等待保证后台运行代码块的数量**


## 代码


```bash

#!/bin/sh
#
# Author: uyinn
# mailto: uyinn@live.com
# datetime: 2014/04/28
#
#

# 创建管道
fifofile=/tmp/my.fifo
mkfifo $fifofile
exec 6<> $fifofile			# @1
rm -f $fifofile

# 实现并发进程数(7个)
# 即在创建的管道中加入进程数个空行
for i in $(seq 7)
do
	echo
done >&6				# @1

# 实现并发
for i in $(seq 100)
do
	read -u 6	#读取管道中的空行，无空行时等待		# @2
	{			
		ransleep=$(($RANDOM%10))
		echo " $i ----- sleep ${ransleep}s"
		sleep $ransleep		# 模拟代码执行时间
		echo >&6	# 带管道中添加空行，保证并发数量
	}&			# 区块代码，即需要并发执行的代码	# @3

done
wait			# 等待执行完成后退出

# 释放管道
exec 6>&-		# 删除文件描述符


```


## 代码说明

+ 重定向内容到描述符是，描述符必须与重定向符号相连，之间不能有空格，否则会报错
+ 通过 read -u 的等待来控制后台的数量。也可以写成 read -u6 。
+ 并发的本质就是将代码放入后台执行。

[ 原文地址](http://hi.baidu.com/khcpubbaordktue/item/c75c24b0665a59961946979f )

