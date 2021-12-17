---
date: "2021-12-07T00:00:00Z"
description: mysql 查询操作
featuredImagePreview: topic/db.png
keywords: mysql
tags:
- mysql
title: mysql 查询操作
typora-root-url: ../../
---

# mysql 查询操作



## 初始化环境

### 创建数据库， 

```sql
-- create database
create database day111 default charset utf8 collate utf8_general_ci;

use day111;
```



### 创建用户表





![image-20211207233206975](/assets/img/post/2021/2021-12-07-mysql-select-operation/image-20211207233206975.png)

```sql
-- create table user

create table user (
  id int not null primary key auto_increment,
  name varchar(6) not null,
  password varchar(32) not null,
  age int,
  salary int  null default 0,
  depart_id int not null
) default charset=utf8;


-- 
insert into `user`
	(name, `password`, age, salary,depart_id) 
values
	("诸葛亮","zhuge123",33,1240,1),
	("关羽","guanyu3234",43,4293,1),
	("曹操","caocao908",42,13000,3),
	("周瑜","zylovexq1314",28,10010,2),
	("张昭","zhang111",84,4500,2);
```

### 创建部门表

![image-20211207232616496](/assets/img/post/2021/2021-12-07-mysql-select-operation/image-20211207232616496.png)

```sql
-- create table depart
create table depart (
  id int not null primary key auto_increment,
  name varchar(10)
) default charset utf8;


-- insert data
insert into depart
	(name)
values
	("蜀国"),
	("吴国"),
	("魏国");

```



查看结果

```sql
mysql> show tables;
+------------------+
| Tables_in_day111 |
+------------------+
| depart           |
| user             |
+------------------+
```



## 单表查询



## 条件查询(where)



```sql
-- 1. 
select * from user;

-- 2. 条件查询
select name, age from user where age > 30;
select * from user where depart_id = 1;

select name,depart_id from user where depart_id!=3;
select name,depart_id from user where depart_id<>3;

-- 3. 模糊查询
select name,`password` from user where `password` like "zh%";
select name,`password` from user where `password` like "zylove__1314";
```



## 查询排序 (order by)



```sql
-- 升序
select name,age from user order by age;
select name,age from user order by age asc;

-- 降序
select name,age from user order by age desc;

-- where , order by
select id, name,age from user
  where id>2
  order by age desc;
```



## 限制结果数量 (limit)

```sql
select id, name,age from user limit 3;

-- where, ordery by, limit
select id, name,age from user where id >2 order by age desc limit 3;
```



## 分组(group by) 与聚合函数

```sql
-- select id,name from user group by depart_id;
-- (1055, "Expression #1 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'day111.user.id' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by")


select count(name), depart_id from user group by depart_id;
select max(age),min(salary), depart_id from user group by depart_id;

-- where, group by , order by, limit;
select max(age), min(salary), depart_id from user 
  where id > 2
  group by depart_id 
  order by max(age) desc
  limit 2;
```



## 分组条件 (having)

```sql
select count(name), max(age), min(salary) from user
  group by depart_id
  having max(age) < 50;


-- where, group by, having, order by, limit
select count(name), max(age), min(salary) from user
  where id > 1
  group by depart_id
  having max(age) <50
  order by max(age) desc
  limit 1;
```



## 联表查询

为了展示 **联表查询** 的差异， 增加 `depart` 字段产生数据差。

```sql
user day111;

-- depart table
insert into depart(name) 
  values ("南蛮"), ("羌笛");
  
select * from depart;

+----+------+
| id | name |
+----+------+
| 1  | 蜀国 |
| 2  | 吴国 |
| 3  | 魏国 |
| 4  | 南蛮 |
| 5  | 羌笛 |
+----+------+

-- user table
--- 修改 name 字段长度 并添加数据
alter table `user` modify column name varchar(128) not null;
insert into user(name, password, age, salary, depart_id)
   values
   ("Jack Sparrow", "jack123", 28, 4921, 10),
   ("Thor Odinson", "thor3432", 8321, 35234, 11);


select * from user;

+----+--------------+--------------+------+--------+-----------+
| id | name         | password     | age  | salary | depart_id |
+----+--------------+--------------+------+--------+-----------+
| 1  | 诸葛亮       | zhuge123     | 33   | 1240   | 1         |
| 2  | 关羽         | guanyu3234   | 43   | 4293   | 1         |
| 3  | 曹操         | caocao908    | 42   | 13000  | 3         |
| 4  | 周瑜         | zylovexq1314 | 28   | 10010  | 2         |
| 5  | 张昭         | zhang111     | 84   | 4500   | 2         |
| 6  | Jack Sparrow | jack123      | 28   | 4921   | 10        |
| 7  | Thor Odinson | thor3432     | 8321 | 35234  | 11        |
+----+--------------+--------------+------+--------+-----------+
```



### `LEFT JOIN .. ON` 与 `RIGHT JOIN .. ON`



![image-20211208165921860](/assets/img/post/2021/2021-12-07-mysql-select-operation/image-20211208165921860.png)



`left/right join .. on` 本质上是一样的， 将多张表 **联结** 成一张 **虚拟表**  进行数据查询。

1. `left / right` 用于相对位置上的 **主表** 。  主表将展示全部数据， 从表 **多的数据不展示** ， **少的数据以 NULL站位** 

2. `on` 指定 **联结 ** 条件。

```sql
-- left join
select * from
 `user` LEFT JOIN depart 
 ON user.depart_id=depart.id;
  
```

![image-20211208170727538](/assets/img/post/2021/2021-12-07-mysql-select-operation/image-20211208170727538.png)

```sql
-- right join

select * from 
  `user` RIGHT JOIN depart
  ON user.depart_id=depart.id;
```



![image-20211208170746896](/assets/img/post/2021/2021-12-07-mysql-select-operation/image-20211208170746896.png)



### 交集 `inner join .. on`

`inner join` 展示交集， 双方都有的。

![image-20211208165951644](/assets/img/post/2021/2021-12-07-mysql-select-operation/image-20211208165951644.png)



```sql
select * from 
  `user` inner join depart
  on user.depart_id = depart.id;
```



![image-20211208170804528](/assets/img/post/2021/2021-12-07-mysql-select-operation/image-20211208170804528.png)



### 并集 `full join .. on`

展示所有数据

![image-20211208170933058](/assets/img/post/2021/2021-12-07-mysql-select-operation/image-20211208170933058.png)

```sql
select * from 
  `user` full join depart
  ON user.depart_id = depart.id;
```

> 注意: mysql 5.7 中不支持 `full join .. on` 。 可以使用 `union + left/right join` 实现

```sql
select * from user LEFT join depart on user.depart_id = depart.id
UNION
select * from user RIGHT join depart on user.depart_id = depart.id;
```

![image-20211208171904801](/assets/img/post/2021/2021-12-07-mysql-select-operation/image-20211208171904801.png)



### 笛卡尔积 `self jion` 自联结

自联结没有关键字， 将多张表以 **逗号 `,`**  分隔， 结果是一张 **笛卡尔积** 的超级大表。

```sql
select * from user,depart;
```



### 联表查询选择字段

查询部分字段时， 需要使用 `table1.columnA, table2.columnB` 的方式 **显示** 指定要查明的字段。

```sql
select user.id, user.name, depart.name from
  user left join depart
  on user.depart_id = depart.id;
```

![image-20211208172154327](/assets/img/post/2021/2021-12-07-mysql-select-operation/image-20211208172154327.png)

### 联表查询条件过滤

联表就是产生一张虚拟表,  对虚拟表的所有 **条件、分组** 都与普通表一样。

```sql
select user.id, user.name, depart.name from
  user left join depart
  on user.depart_id = depart.id
WHERE user.id%2 = 0;
```

![image-20211208172526455](/assets/img/post/2021/2021-12-07-mysql-select-operation/image-20211208172526455.png)





## 查询结果组合 `Union`

union 不是联结原始表， 而是将多个 **结果** 组合成一张表。 

1. **要求** 多个查询结果的 **字段数** 一样
2. **不要求**  多个查询结果字段对应的类型一样。

```sql
select name, age from user where id = 1
UNION
select age, name from user where id = 1;
```



![image-20211208173231200](/assets/img/post/2021/2021-12-07-mysql-select-operation/image-20211208173231200.png)

