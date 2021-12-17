---
date: "2021-12-06T00:00:00Z"
description: mysql table 表操作
image: topic/db.png
keywords: mysql, table
tags:
- mysql
title: mysql table 操作
typora-root-url: ../../
---

# Mysql - table 操作

## 创建数据库

```sql
create database 数据库名 default charset utf8 collate utf8_general_ci;
```



## 查看所有表

```sql
show tables;
```



## 创建数据表

```sql
create table 表名(
  列名 类型,
  列名 类型
) default charset=utf8;

---

create table user (
  id int not null auto_increment primary key,  -- 不允许为空，主键, 自增
  name varchar(16) not null,  -- 不允许为空
  email varchar(32) null, -- 允许为空， 长度为 32
  age int  default 3 -- 默认值
) default charset=urf8;
```

**注意** : 一张表只能 **有且只有一个** 自增列， 一般此列都是主键列。



## 删除表

```sql
drop table 表名;
```



## 清空表



### delete

要生成 binlog

```sql
delete from 表名;

delete from 表名 where id=?;
```

注意:  `delete` 删除数据是， 为 DML 语句， 将会产生 binlog。 如果短时间内删除大量数据将产生大量 binlog 占满硬盘。 在云商数据库 （RDS）中 binlog 文件会占用数据盘总量。



### truncate

速度快，无法回滚或撤销， 不生成 binlog。

```sql
truncate table 表名;
```



## 修改表

### 添加列

```sql
alter table 表名 add 列名 类型;
alter table 表名 add 列名 类型 Default 默认值;
alter table 表名 add 列名 类型 not null default 默认值;
alter table 表名 add 列名 类型 not null primary key auto_increment;
```



### 删除列

```sql
alter table 表名 DROP column 列名;
```



### 修改列 - 类型

```sql
alter table 表名 MODIFY column 列名 类型;
```

#### 修改列 - 类型+名称

```sql
alter table 表名 CHANGE 列名 新列名   新类型 [属性];

---

alter table 表名 CHANGE id   id      int   not null;
alter table 表名 CHANGE id   uid     int;

```

#### 修改列 - 默认值

```sql
-- 修改默认值
alter table 表名 ALTER 列名 SET DEFAULT 1000;

----

-- 删除默认值
alter table 表名 ALTER 列名 DROP DEFAULT;
```



#### 修改列 - 添加主键

```sql
alter table 表名 ADD primary key(列名);
```



#### 修改列 -  删除主键

```sql
alter table 表名 DROP primary key;
```



## 数据操作

###  `insert` 插入数据

**具名插入**: 将对应的值插入到对应的列中。 因此列的顺序可以不一致。

```sql
insert into 表名(列1, 列9, 列4) VALUES(value1, value9, value4);
```

**默认插入**:  将对应值按照顺序插入到数据库表的列中， 顺序不能错乱。

```sql
intert into 表名 VALUES(value1, value2, value3, ..., value9);
```
