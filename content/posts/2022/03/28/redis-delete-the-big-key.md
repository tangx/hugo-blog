---
title: "Redis 删除大 key"
subtitle: "Redis Delete the Big Key"
date: 2022-03-28T10:17:52+08:00
lastmod: 2022-03-28T10:17:52+08:00
draft: false
author: ""
authorLink: ""
description: ""

tags: []
categories: []

hiddenFromHomePage: false
hiddenFromSearch: false

featuredImage: ""
featuredImagePreview: ""

toc:
  enable: true
math:
  enable: false
lightgallery: false
license: ""
---


## 什么是 Redis 大 Key

1. `string` 类型中的值大于 `10kb`
2. `hash, list, set, zset` 中的元素超过 `5000个`


## 如何查找大 Key

1. `string` 通过命令直接查找

```bash
redis-cli -h 127.0.0.1 -p6379 -a "YourPassword" --bigkeys
```

2. 使用 `RdbTools` 工具

```bash
rdb dump.rdb -c memory --bytes 10240 -f redis.csv
```


## 怎么删除 Redis 中的 大 Key

**风险点**: 直接删除大 Key 会造成阻塞。 由于 redis 是 **单线程** 执行， 阻塞可能造成其他所有请求超时。 如果超时越来越多，则可能会造成 redis 链接耗尽， 引发其他异常。


因此， 解决方案可以有如下几种选择

1. **业务低峰期删除** ： 配合 redis 的监控， 在业务低峰期进行删除。 但这也是治标不治本， 没有真正解决 **阻塞** 问题。
2. **分批次删除** : 大事化小
    + `hash` 使用 `hsacn` 扫描法。
    + `set` 使用 srandmember 每次随机抽取数据删除。
    + `zset` 使用 `zremrangebyrank` 删除
    + `list` 使用 `pop` 删除
3. **异步删除**: 使用 `unlink` 命令 代替 `del` 命令。 使用 `unlink` 后， redis 会将 key 放入到一个 **异步线程** 中进行删除， 这样就不会阻塞主线程了。


## redis 中的删除方法 `del` 和 `unlink`

+ del命令使用同步删除，unlink使用异步删除。
+ 在删除数据体量很小的简单类型时建议使用del命令，在删除大key时应该使用unlink命令。
+ 删除小key使用del的原因是：虽然del是同步删除，会阻塞主线程，但是unlink同样会在主线程执行一些判断和其它操作。而这些操作可能带来的开销比实际删除一个小key还略大。所以能直接删的key就没必要使用异步删除了。


```ini
############################# LAZY FREEING ####################################

# Redis has two primitives to delete keys. One is called DEL and is a blocking
# deletion of the object. It means that the server stops processing new commands
# in order to reclaim all the memory associated with an object in a synchronous
# way. If the key deleted is associated with a small object, the time needed
# in order to execute the DEL command is very small and comparable to most other
# O(1) or O(log_N) commands in Redis. However if the key is associated with an
# aggregated value containing millions of elements, the server can block for
# a long time (even seconds) in order to complete the operation.
#
# For the above reasons Redis also offers non blocking deletion primitives
# such as UNLINK (non blocking DEL) and the ASYNC option of FLUSHALL and
# FLUSHDB commands, in order to reclaim memory in background. Those commands
# are executed in constant time. Another thread will incrementally free the
# object in the background as fast as possible.
#
# DEL, UNLINK and ASYNC option of FLUSHALL and FLUSHDB are user-controlled.
# It's up to the design of the application to understand when it is a good
# idea to use one or the other. However the Redis server sometimes has to
# delete keys or flush the whole database as a side effect of other operations.
# Specifically Redis deletes objects independently of a user call in the
# following scenarios:
#
# 1) On eviction, because of the maxmemory and maxmemory policy configurations,
#    in order to make room for new data, without going over the specified
#    memory limit.
# 2) Because of expire: when a key with an associated time to live (see the
#    EXPIRE command) must be deleted from memory.
# 3) Because of a side effect of a command that stores data on a key that may
#    already exist. For example the RENAME command may delete the old key
#    content when it is replaced with another one. Similarly SUNIONSTORE
#    or SORT with STORE option may delete existing keys. The SET command
#    itself removes any old content of the specified key in order to replace
#    it with the specified string.
# 4) During replication, when a replica performs a full resynchronization with
#    its master, the content of the whole database is removed in order to
#    load the RDB file just transferred.
#
# In all the above cases the default is to delete objects in a blocking way,
# like if DEL was called. However you can configure each case specifically
# in order to instead release memory in a non-blocking way like if UNLINK
# was called, using the following configuration directives:

lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no
```