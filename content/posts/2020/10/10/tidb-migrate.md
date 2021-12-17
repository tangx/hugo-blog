---
date: "2020-10-10T00:00:00Z"
description: tidb 的备份与迁移使用 tidb enterprise tools 进行操作。
keywords: database, tidb, transfer
tags:
- database
- tidb
title: tidb 备份恢复与迁移
---

# tidb 备份恢复与迁移

> https://pingcap.com/docs-cn/v2.1/reference/tools/download/

```bash
wget https://download.pingcap.org/tidb-enterprise-tools-latest-linux-amd64.tar.gz
```

## 使用 mydumper 从 mysql/tidb 备份数据

> https://pingcap.com/docs-cn/v2.1/how-to/maintain/backup-and-restore/

### 使用 mydumper 备份

mydumper: https://github.com/maxbube/mydumper/releases

```bash
mydumper -h 127.0.0.1 -P 4000 -u root -t 32 -F 64 -B test -T t1,t2 --skip-tz-utc -o ./var/test
```

我们使用 `-B test` 表明是对 test 这个 database 操作，然后用 `-T t1,t2` 表明只导出 t1，t2 两张表。

`-t 32` 表明使用 32 个线程去导出数据。-F 64 是将实际的 table 切分成多大的 chunk，这里就是 64MB 一个 chunk。

`--skip-tz-utc` 添加这个参数忽略掉 TiDB 与导数据的机器之间时区设置不一致的情况，禁止自动转换。


### 字符集转换

目前 TiDB 支持 UTF8mb4 字符编码，假设 Mydumper 导出数据为 latin1 字符编码，请使用

```bash
iconv -f latin1 -t utf-8 $file -o /data/imdbload/$basename

# iconv -f latin1 -t utf-8 iot_env_data.t_env_data_vehicle-schema.sql  -o /data1/iot_mysql_2_tidb/iot_env_data-by-mydump--utf8/iot_env_data.t_env_data_vehicle-schema.sql

```

## 使用 loader 恢复数据到 tidb

### 修改 tidb gc 时间

```sql
SELECT * FROM mysql.tidb WHERE VARIABLE_NAME = 'tikv_gc_life_time';
-- +-----------------------+----------------------------------+
-- | VARIABLE_NAME         | VARIABLE_VALUE                   |
-- +-----------------------+----------------------------------+
-- | tikv_gc_life_time     | 10m0s                            |
-- +-----------------------+----------------------------------+
-- 1 rows in set (0.02 sec)

update mysql.tidb set VARIABLE_VALUE = '720h' where VARIABLE_NAME = 'tikv_gc_life_time';

```

### 导入文件
```bash
loader  -h 127.0.0.1 -u root -P 4000 -t 32 -d ./var/test
```

### 还原 tidb gc 时间

```sql
update mysql.tidb set VARIABLE_VALUE = '10m' where VARIABLE_NAME = 'tikv_gc_life_time';
```

> 注意: 使用 `loader` 的时候，如果出现异常或者冲突。**不能**直接修改 `sql` 文件，否则可能出现各种异常。
>> 建议在专业的 DBA 指导下执行。


## 使用 syncer 增量迁移

使用 `syncer` 进行数据库的增量迁移， 依赖 `mydumper` 的 metadata 数据

> https://pingcap.com/docs-cn/v2.1/how-to/migrate/incrementally-from-mysql/


## 更多高级备份

### 使用 tidb lightning 从底层实现数据导入

TiDB Lightning 是一个将全量数据高速导入到 TiDB 集群的工具，有以下两个主要的使用场景：一是大量新数据的快速导入；二是全量数据的备份恢复。目前，支持 Mydumper 或 CSV 输出格式的数据源。你可以在以下两种场景下使用 Lightning：

+ 迅速导入大量新数据。
+ 备份恢复所有数据。

![tidb-lightning-architecture.png](https://download.pingcap.com/images/docs-cn/tidb-lightning-architecture.png)

> https://pingcap.com/docs-cn/v2.1/reference/tools/tidb-lightning/overview/

### 数据迁移 Data Migration 

DM (Data Migration) 是一体化的数据同步任务管理平台，支持从 MySQL 或 MariaDB 到 TiDB 的全量数据迁移和增量数据同步。使用 DM 工具有利于简化错误处理流程，降低运维成本。

> https://pingcap.com/docs-cn/v2.1/reference/tools/data-migration/overview/#dm-架构

![https://download.pingcap.com/images/docs-cn/dm-architecture.png](https://download.pingcap.com/images/docs-cn/dm-architecture.png)

## sync-diff-inspector 数据一致性比较

> https://pingcap.com/docs-cn/v2.1/reference/tools/sync-diff-inspector/overview/

