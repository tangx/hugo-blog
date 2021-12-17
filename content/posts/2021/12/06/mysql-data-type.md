---
date: "2021-12-06T00:00:00Z"
description: Mysql 常见数据类型 int char timestamp
featuredImagePreview: /assets/topic/db.png
keywords: mysql
tags:
- mysql
title: Mysql 常见数据类型 int char timestamp
typora-root-url: ../../
---

# Mysql 数据类型

> https://dev.mysql.com/doc/refman/5.7/en/data-types.html



## 整数类型

```sql
mysql root@localhost:db1> create table table_int(
                              int_no int unsigned,
                              biging_no bigint,
                              tinyint_no tinyint
                          ) default charset=utf8;
                          
Query OK, 0 rows affected
Time: 0.028s
```



### `int`

取值范围 `-2^31 ~ 2^31-1`

+ `unsigned` : 取之范围 `0 ~ 2^32-1`

### `bigint`

取值范围 `-2^63 ~ 2^63-1`



### `tinyint`

取值范围 `-128 ~ 127`

## 小数类型



### `Float`

使用 32位浮点数保存。 不精确。

### `Double`

使用 64 位浮点数保存。 不精确。



### `Decimal`

`decimal` 精确的小数值，

+  `m` 数字的总个数（**负号部分不算**， 含 **小数部分**）; `d` 是小数点后面部分。
+  `m` 最大为 65， `d` 最大为 30 。





创建数据表

```sql
-- 创建库
create database db1 default charset utf8 collate utf8_general_ci;

-- 创建表
create table L2 ( 
  id int not null auto_increment primary key, 
  salary decimal(8,2) 
) default charset =utf8;

```





#### Decimal 进位 - 四舍五入

```sql
mysql root@localhost:db1> insert into `L2` (salary) values (1.28);
Query OK, 1 row affected
Time: 0.004s

-- 舍去
mysql root@localhost:db1> insert into `L2` (salary) values( 2.33333);
Query OK, 1 row affected
Time: 0.004s

-- 进位
mysql root@localhost:db1> insert into `L2` (salary) values(6.66666);
Query OK, 1 row affected
Time: 0.004s

-- 查询
mysql root@localhost:db1> select * from `L2`;
+----+--------+
| id | salary |
+----+--------+
| 1  | 1.28   |
| 2  | 2.33   |  -- 2.3333, 2位小数后的值被舍去了。
| 3  | 6.67   |  -- 6.6666, 2为小数后的值被进位了。
+----+--------+
3 rows in set
Time: 0.010s
```



####  Decimal 长度

可以看到，  **总长度为 8 小数为 2** 的 `decimal`字段， 其 **正数** 部分长度只能为 **6** 

```sql
-- 超长， 总长超长
mysql root@localhost:db1> insert into `L2` (salary) values(1234567.890);
(1264, "Out of range value for column 'salary' at row 1")

-- 超长， 正数超长
mysql root@localhost:db1> insert into `L2` (salary) values(1234567);;
(1264, "Out of range value for column 'salary' at row 1")

-- 正确, 小数补齐
mysql root@localhost:db1> insert into `L2` (salary) values(123456);;
Query OK, 1 row affected
Time: 0.004s

-- 正确
mysql root@localhost:db1> insert into `L2` (salary) values(123456.78);;
Query OK, 1 row affected
Time: 0.004s

mysql root@localhost:db1> select * from `L2`;
+----+-----------+
| id | salary    |
+----+-----------+
| 4  | 123456.00 |  -- 小数补齐
| 5  | 123456.78 |
+----+-----------+
5 rows in set
Time: 0.010s
```

 

## 字符串类型

在  `utf8` 模式下， **一个中文字符** 占用 **三个字节** 。

```sql
mysql root@localhost:db1> create table table_char (
                              char_string char(10) ,
                              varchar_string varchar(10)
                          ) default charset=utf8;
```



```sql
-- 12个中文字符超长
mysql root@localhost:db1> insert into table_char(varchar_string) values ("无论插入数据是否为最大");
(1406, "Data too long for column 'varchar_string' at row 1")

-- 14个英文字符超长
mysql root@localhost:db1> insert into table_char(varchar_string) values ("12345678901234");
(1406, "Data too long for column 'varchar_string' at row 1")


-- 10个 中/英文 字符刚好
mysql root@localhost:db1> insert into table_char(varchar_string) values ("无论插入数据是否为最");
Query OK, 1 row affected
Time: 0.004s

mysql root@localhost:db1> insert into table_char(varchar_string) values ("1234567890");
Query OK, 1 row affected
```



### `char(m)` 定长

+ 最大长度为 255 个 **字符 characters** 。
+ 数据使用 **固定长度** 保存。 无论插入数据是否为最大值， 都将消耗与设置大小的空间。
+ 当插入数据超长时， 严格模式下 **报错**， 兼容模式下 **截断** 。

### `varchar(m)` 变长

+ 最大长度 65535个 **字节 bytes** (mysql5.7)  。 有多少 **字符**  ， 消耗多少空间。

> https://dev.mysql.com/doc/refman/5.7/en/char.html

虽然文档 varchar 保存的是字节。 但是在测试中可以保存 10 个汉字。

### `text` / `mediumtext` / `longtext`

用于保存 **变长** 的大字符串。

- TEXT `65,535 bytes ~64kb`
- MEDIUMTEXT `16,777,215 bytes ~16Mb`
- LONGTEXT `4,294,967,295 bytes ~4Gb`

```sql
mysql root@localhost:db1> create table table_text(
                              col_text text,
                              col_medium mediumtext,
                              col_long longtext
                          ) default charset=utf8;

Query OK, 0 rows affected
Time: 0.028s
```



## 时间类型



```sql
mysql> create table table_time (
         ts timestamp,
         dt datetime
     	) default charset=utf8;
Query OK, 0 rows affected (0.02 sec)
```



### `datetime`

`datetime` 将当前运行环境时间直接保存到数据库中。  因此 **受运行环境的时区影响** 。 例如中国区的 `+08:00` 。

```
YYYY-MM-DD HH:MM:SS (1000-01-01 00:00:00 ~ 9999-12-31 23:59:59)
```

### `timestamp`

`timestamp` 在插入时客户端会将当前时区转换为 UTC 时间后，再计算 timestamp 进行存储；  查询时将 timestamp 的值转换为当前时区展示。

因此 timestamp 的使用时不受 **运行环境** 时区影响的。

```
YYYY-MM-DD HH:MM:SS (1970-01-01 00:00:00 ~ 2037年?月?日)
```



### `date` 年月日

```
YYYY-MM-DD
```



### `time` 时分秒

```
HH:MM::SS
```

