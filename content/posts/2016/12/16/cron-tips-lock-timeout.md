---
date: "2016-12-16T00:00:00Z"
description: cron 定时任务小技巧 进程锁与超时
keywords: keyword1, keyword2
tags:
- system
title: cron 定时任务小技巧 进程锁与超时
---

# cron 定时任务小技巧 进程锁与超时

如果本文的内容仅限于此类小菜，那么未免有些太对不起各位看官，下面上一道硬菜：设置一个 PHP 脚本，每分钟执行一次，怎么搞？听起来这分明就是一道送分题啊：

```bash
* * * * * /path/to/php /path/to/file
```

让我们设想如下情况：假如上一分钟的 A 请求还没退出，下一分钟的 B 请求也启动了，就会导致出现 AB 同时请求的情况，如何避免？答案是 flock，它实现了锁机制：

```bash
flock -xn /tmp/lock /path/to/php /path/to/file
```

让我们再来重放一下故障场景：假如上一分钟的 A 请求还没退出，下一分钟的 B 请求也启动了，那么 B 请求会发现 A 请求还没有释放锁，于是它不会执行。

看起来似乎完美解决了问题，不过让我们在加入一点特殊情况：假如因为某些无法预知的原因，导致脚本不能正常结束请求，进而导致不能正常释放锁，那么后续所有其它的 CD 等请求也都无法执行了，如何避免？答案是 timeout，它实现了超时控制机制：

```bash
timeout -s SIGINT 100 flock -xn /tmp/lock /path/to/php /path/to/file
```
