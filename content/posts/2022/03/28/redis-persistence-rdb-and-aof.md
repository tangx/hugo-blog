---
title: "Redis 持久化方式 - RDB 和 AOF"
subtitle: "Redis Persistence RDB and AOF"
date: 2022-03-28T18:19:59+08:00
lastmod: 2022-03-28T18:19:59+08:00
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

# Redis 持久化

Redis 持久化数据支持 `AOF (append-only files)` 和 `Rdb (snapshot)` 两种方式。 在为 Redis 选择硬盘的时候， 最好选择 `SSD` 高性能硬盘。

Redis 持久化的四种选择:

1. **RDB (Redis Database)**: 创建 **快照**， 将内存中的 **当前数据** 状态进行 **全量备份** 。
2. **AOF (Append-Only File)**: 以 **写入操作** 的 **操作日志** 形式存储到备份文件中。 恢复数据时重放所有操作。 类似 Mysql 的 Binlog
3. **RDB + AOF**: 兼顾了 RDB 和 AOF 的优点。
4. **No persistence**: 不进行持久化。 如果数据允许丢失， 例如完全为数据库缓存， 则可以不进行持久化。


## RDB 备份

### RDB 优点

1. RDB 备份时间是 Redis 在某个时间点的内存快照。 RDB 文件非常适合备份。例如，您可能希望在最近的 24 小时内每小时归档一次 RDB 文件，并在 30 天内每天保存一个 RDB 快照。这使您可以在发生灾难时轻松恢复不同版本的数据集。
2. RDB 是异地容灾备份 (保存在 s3) 的一个不错的选择。 
3. RDB 最大限度地提高了 Redis 的性能，因为 Redis 父进程为了持久化而需要做的唯一工作就是派生一个将完成所有其余工作的子进程。父进程永远不会执行磁盘 I/O 或类似操作。
4. 与 AOF 相比，RDB 允许使用大数据集更快地重启。

### RDB 缺点

1. RDB 丢失数据的的间隔周期比 AOF 长。 这是由于 RDB 备份规则触发器的所导致的。 **时间间隔** 和 **写入数据频率** 触发。
2. RDB 需要经常 fork() 以便使用子进程在磁盘上持久化。如果数据集很大，fork() 可能会很耗时，并且如果数据集很大并且 CPU 性能不是很好，可能会导致 Redis 停止为客户端服务几毫秒甚至一秒钟。AOF 也需要 fork() 但频率较低，您可以调整要重写日志的频率，而不需要对持久性进行任何权衡。


## AOF 备份

### AOF 优势

1. 使用 AOF Redis 更加持久：您可以有不同的 fsync 策略：根本不 fsync、每秒 fsync、每次查询时 fsync。使用每秒 fsync 的默认策略，写入性能仍然很棒。fsync 是使用后台线程执行的，当没有 fsync 正在进行时，主线程将努力执行写入，因此您只能丢失一秒钟的写入。
2. AOF 日志是一个仅附加日志，因此不会出现寻道问题，也不会在断电时出现损坏问题。即使由于某种原因（磁盘已满或其他原因）日志以写一半的命令结尾，redis-check-aof 工具也能够轻松修复它。
3. 当 AOF 变得太大时，Redis 能够在后台自动重写 AOF。重写是完全安全的，因为当 Redis 继续附加到旧文件时，会使用创建当前数据集所需的最少操作集生成一个全新的文件，一旦第二个文件准备就绪，Redis 就会切换两者并开始附加到新的那一个。
4. AOF 以易于理解和解析的格式依次包含所有操作的日志。您甚至可以轻松导出 AOF 文件。例如，即使您不小心使用该FLUSHALL命令刷新了所有内容，只要在此期间没有执行日志重写，您仍然可以通过停止服务器、删除最新命令并重新启动 Redis 来保存您的数据集.


### AOF 缺点

1. AOF 文件通常比相同数据集的等效 RDB 文件大。 因为记录了所有操作日志。
2. 根据确切的 fsync 策略，AOF 可能比 RDB 慢。一般来说，将 fsync 设置为每秒的性能仍然非常高，并且在禁用 fsync 的情况下，即使在高负载下它也应该与 RDB 一样快。即使在巨大的写入负载的情况下，RDB 仍然能够提供关于最大延迟的更多保证。
3. Redis 版本低于 7.0 的时候， 会有以下劣势
    + 如果在重写期间有对数据库的写入，AOF 可能会使用大量内存（这些被缓冲在内存中并在最后写入新的 AOF）
    + 重写期间到达的所有写入命令都会写入磁盘两次。
    + Redis 可以在重写结束时冻结写入并将这些写入命令同步到新的 AOF 文件。
