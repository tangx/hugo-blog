---
date: "2021-12-06T00:00:00Z"
description: Mysql 基础练习 01
image: topic/db.png
keywords: mysql
tags:
- mysql
title: Mysql 基础练习 01
typora-root-url: ../../
---
# Mysql 基础练习 01

![image-20211206172823222](/assets/img/post/2021/2021-12-06-mysql-pratice-01/image-20211206172823222.png)
1. 根据表格创建数据库表，注意编码。
```sql
create database db01 default charset utf8 collate utf8_general_ci;
use db01;
create table userinfo (
   id int not null auto_increment primary key,
   name varchar(32) not null,
   password varchar(64) not null,
   gender enum('male','female') not null,
   email varchar(64) not null,
   amount decimal(10,2) not null default 0,
   ctime datetime
) default charset=utf8;



show tables;
+----------------+
| Tables_in_db01 |
+----------------+
| userinfo       |
+----------------+
1 row in set
```

1. 插入任意五条数据

```sql

insert into userinfo(name,`password`,gender,email) 
   values("zhangsan","zhang123","male","zhangsan@example.com");

insert into userinfo(name, `password`, gender,email) 
   values("murong","murong123","female","murong@example.com");

insert into userinfo(name,`password`,gender,email,amount)
   values ("waner","waner123","female", "waner@example.com",1234.123);

insert into userinfo(name,`password`,gender,email,amount)
   values ("wangwu","wangwu123","male","wangwu@example.com",3432.23);

insert into userinfo(name,`password`,gender,email,amount)
   values("wangyuyan","wang123","female","wangyuyan@example.com",394023);

select * from userinfo;
+----+-----------+-----------+--------+-----------------------+-----------+--------+
| id | name      | password  | gender | email                 | amount    | ctime  |
+----+-----------+-----------+--------+-----------------------+-----------+--------+
| 1  | zhangsan  | zhang123  | male   | zhangsan@example.com  | 0.00      | <null> |
| 2  | murong    | murong123 | female | murong@example.com    | 0.00      | <null> |
| 3  | waner     | waner123  | female | waner@example.com     | 1234.12   | <null> |
| 4  | wangwu    | wangwu123 | male   | wangwu@example.com    | 3432.23   | <null> |
| 5  | wangyuyan | wang123   | female | wangyuyan@example.com | 394023.00 | <null> |
+----+-----------+-----------+--------+-----------------------+-----------+--------+
(END)
```



**非法数据**： 由于 gender 列使用的是 `enum` ， 只能接受 `male / female`。

```sql
insert into userinfo(name,`password`,gender,email,amount) 
    values("zhugeliang","zhuge123",123,"zhuge@example.com",123124);
(1265, "Data truncated for column 'gender' at row 1")
```



1. 将 `id>3` 的所有人性别改为男。

```sql
-- 原值
select name,gender from userinfo where id>3;
+-----------+--------+
| name      | gender |
+-----------+--------+
| wangwu    | male   |
| wangyuyan | female |
+-----------+--------+
2 rows in set
Time: 0.011s

-- 更改
update userinfo set gender='male' where id > 3;
Query OK, 1 row affected
Time: 0.005s

-- 新值
select name,gender from userinfo where id>3;
+-----------+--------+
| name      | gender |
+-----------+--------+
| wangwu    | male   |
| wangyuyan | male   |
+-----------+--------+
2 rows in set
Time: 0.010s
```



1. 查询余额 `amount > 1000` 的所有用户。

```sql
select name,amount from userinfo where amount> 1000;
+-----------+-----------+
| name      | amount    |
+-----------+-----------+
| waner     | 1234.12   |
| wangwu    | 3432.23   |
| wangyuyan | 394023.00 |
+-----------+-----------+
3 rows in set
Time: 0.019s
```



1. 让所有人余额原地 `+1000`

```sql
-- 原值
select name,amount from userinfo;
+-----------+-----------+
| name      | amount    |
+-----------+-----------+
| zhangsan  | 0.00      |
| murong    | 0.00      |
| waner     | 1234.12   |
| wangwu    | 3432.23   |
| wangyuyan | 394023.00 |
+-----------+-----------+
5 rows in set
Time: 0.012s

-- 更新
update userinfo set amount=amount+1000;
Query OK, 5 rows affected
Time: 0.004s

-- 新值
select name,amount from userinfo;
+-----------+-----------+
| name      | amount    |
+-----------+-----------+
| zhangsan  | 1000.00   |
| murong    | 1000.00   |
| waner     | 2234.12   |
| wangwu    | 4432.23   |
| wangyuyan | 395023.00 |
+-----------+-----------+
5 rows in set
Time: 0.010s
```



1. 删除所有性别为 男 的数据。

```sql
-- 删除前
select name,gender from userinfo where gender='male';
+-----------+-----------+
| name      | gender    |
+-----------+-----------+
| zhangsan  | male      |
| wangwu    | male      |
| wangyuyan | male      |
+-----------+-----------+
3 rows in set
Time: 0.010s

-- 删除
delete from userinfo where gender='male';
Query OK, 3 rows affected
Time: 0.004s

-- 删除后, 查询所有, 看不到男人了
select name,gender from userinfo;
+--------+--------+
| name   | gender |
+--------+--------+
| murong | female |
| waner  | female |
+--------+--------+
2 rows in set
Time: 0.012s
```

