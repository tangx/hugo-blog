---
date: "2020-04-23T00:00:00Z"
description: tidb 备份迁移手札
keywords: tidb, database
tags:
- database
- tidb
title: TiDB 2.1 备份恢复与迁移
---

# TiDB 2.1 备份恢复与迁移


## 备份

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

## 恢复

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

### 导入 文件
```bash
loader  -h 127.0.0.1 -u root -P 4000 -t 32 -d ./var/test
```

### 还原 tidb gc 时间

```sql
update mysql.tidb set VARIABLE_VALUE = '10m' where VARIABLE_NAME = 'tikv_gc_life_time';
```
