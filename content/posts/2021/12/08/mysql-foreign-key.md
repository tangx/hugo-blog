---
date: "2021-12-08T00:00:00Z"
description: Mysql 外键
featuredImagePreview: topic/db.png
keywords: mysql
tags:
- mysql
title: Mysql 外键
typora-root-url: ../../
---

# Mysql 外键

如果说 mysql 中的 `left/right/out join`  查询 **软链接** 关系， 只是通过看似有关系的字段把两张表聚合在一起。 

那么 `foreign key`  就是 **硬连接** ， 实实在在把两张表聚合在一起。 如果数据的字段的值 **不符合** 所连接表， 将不允许输入 **插入或修改** 数据。



![image-20211209071918446](/assets/img/post/2021/2021-12-08-mysql-foreign-key/image-20211209071918446.png)



## 创建外键

### 准备环境

```sql
create database day123 default charset utf8 collate utf8_general_ci;
use day123;

create table depart(
  id int not null primary key auto_increment,
  name varchar(32) not null
) default charset=utf8;

```



### 创建表的时候创建外键约束

创建 user 表的时候， 关联 `user.depart_id -> depart.id`

```sql
create table user (
  id int not null primary key auto_increment,
  name varchar(32) not null,
  password varchar(32) not null,
  age int,
  salary int,
  depart_id int not null,
  
  -- 设置外键关系
  CONSTRAINT fk_user_depart FOREIGN KEY (depart_id) REFERENCES depart(id)

) default charset=utf8;
```

### 为已有的表增加外键约束

```sql
create table salary(
  id int not null primary key auto_increment,
  salary int,
  user_id
) default charset utf8;


-- 新增外键约束
alter table salary ADD
  CONSTRAINT fk_salary_user FOREIGN KEY salary(user_id) REFERENCES user(id);
```

> 注意： alter 增加外键的时候， 外键列是  `table(column)` 。 

### 删除外键

```sql
alter table salary
  DROP FOREIGN KEY fk_salary_user;

```



## 插入数据

```sql

-- user table
-- 
insert into `user`
	(name, `password`, age, salary,depart_id) 
values
	("关羽","guanyu3234",43,4293,1),
	("曹操","caocao908",42,13000,3),
	("周瑜","zylovexq1314",28,10010,2),
	("张昭","zhang111",84,4500,2);
	
```



### 外间数据存在， 成功插入

管理 depart 表的值

```sql

-- 重置 auto_increment 值
ALTER TABLE depart AUTO_INCREMENT = 1;

insert into depart
	(name)
values
	("蜀国"),
	("吴国"),
	("魏国");
```

管理 user 表的值

```sql

insert into `user`
	(name, `password`, age, salary,depart_id) 
values
	("诸葛亮","zhuge123",33,1240,1),
	("关羽","guanyu3234",43,4293,1),
	("曹操","caocao908",42,13000,3),
	("周瑜","zylovexq1314",28,10010,2),
	("张昭","zhang111",84,4500,2);
```



### 当外键盘数据不存在时， 插入失败

提示外键关联不正确。



```sql
-- 外键数据

insert into `user`
	(name, `password`, age, salary,depart_id) 
values
	("Jack Sparrow","jack5432",33,1240,11);



(1452, 'Cannot add or update a child row: a foreign key constraint fails (`day123`.`user`, CONSTRAINT `fk_user_depart` FOREIGN KEY (`depart_id`) REFERENCES `depart` (`id`))')
```





## 被关联的表删除

### 不能直接使用 `truncate`

使用 `truncate` 清理被关联的表的时候报错如下

```sql
truncate depart;

(1701, 'Cannot truncate a table referenced in a foreign key constraint (`day123`.`user`, CONSTRAINT `fk_user_depart` FOREIGN KEY (`depart_id`) REFERENCES `day123`.`depart` (`id`))')
```

> truncate 使用场景: https://segmentfault.com/a/1190000022254508



### 可以使用 `delete from`

```sql
delete from depart;

Query OK, 3 rows affected
Time: 0.005s
```

