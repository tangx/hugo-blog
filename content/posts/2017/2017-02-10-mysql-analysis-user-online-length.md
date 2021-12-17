---
date: "2017-02-10T00:00:00Z"
description: 查询 MYSQL 查询结果, MYSQL 函数
keywords: mysql
tags:
- mysql
title: 使用 mysql 统计平均用户在线时长
---

# 使用 mysql 统计平均用户在线时长

在表中，记录了用户 login/logout 的时间点（unix时间）。现在需要确定当日用户的在线时长总和，与平均在线时长。
简单的说，就是要求出匹配 userid 的 login/logout timestamp 的差值并求和。
问题在于：

+ 其一，某些用户是跨天 login 或者 logout 的，这样当天的日志就没有可以匹配的 userid_login / userid_logout 。
+ 其二，如果有些重度用户长时间在线，例如跨三天；那么第二天就没有其 login/logout 的日志。这样数据将会丢失。


## 跨天的问题

这里将用户的游戏时间分为两部分。即，当天没 logout 记录，则使用 `23:59:59` 作为退出时间；当天没有 login 记录，则使用 `00:00:00` 作为上线时间。


![login_logout_timestamp.png](/assets/img/post/2017/2017-02-10-login_logout_timestamp.png)


一条记录中，最简单的计算公式是 `userid_logout_timestamp - userid_login_timestamp`。

根据之前分析的情况，这里可以分为三种情况：

+ login/logout 记录匹配：`c_timestamp - b_timestamp` -> `(end_timestamp - b_timestamp) + (c_timestamp - start_timestamp) - (end_timestamp - start_timestamp)`。
+ 只有 login 记录：`end_timestamp - b_timestamp`
+ 只有 logout 记录： `c_timestamp - start_timestamp`

这里 `(end_timestamp - start_timestamp)` 就是整个线段，即一天的时间长度。

最后，所有记录求和，就得到公式：

`( count(b)*end_timestamp - sum(b_timestamp) ) + ( sum(c_timestamp) - count(c)*start_timestamp ) - ( count(couple)*(end_timestamp - start_timestamp) )`

> 注： count(couple) 为 login/logout 成功匹配的次数。


```sql
-- 1.sql 计算用户 login/logout 总次数及 timestamp的时间总和。
SELECT COUNT(login_type),login_type,SUM(login_timestamp) FROM tablename20101010
GROUP BY svr_id,channel_id,login_type;

-- 2.sql 计算单个用户的 login/logout 分别次数。
SELECT user_id,login_type,svr_id,channel_id,COUNT(login_type) FROM tablename20101010 
GROUP BY svr_id,channel_id,user_id,login_type;

-- 3.sql 计算单个用户的 login/logout 匹配次数。
SELECT user_id,login_type,svr_id,channel_id,FLOOR(COUNT(login_type)/2) FROM tablename20101010
GROUP BY svr_id,channel_id,user_id;


-- 4.sql 计算所有用户的 login/logout 匹配次数。
SELECT t1.svr_id,t1.channel_id,SUM(t1.user_couple_record) FROM
(SELECT user_id,login_type,svr_id,channel_id,FLOOR(COUNT(login_type)/2) AS user_couple_record FROM tablename20101010
GROUP BY svr_id,channel_id,user_id) AS t1
GROUP BY t1.svr_id,t1.channel_id 
ORDER BY t1.svr_id,t1.channel_id ;

```

> 注意1：在 3.sql 中：这里是统计单个用户的所有 login/logout 记录，之后除以2。使用了函数 `FLOOR()` 向下取整，求出成功匹配次数。
> 

> 注意2：在 4.sql 中：对第一次查询结果进行第二次查询。这里必须对第一次结果使用别名，这样在内存(缓存？？)就生成了一张新的表。 
> 这里创建表别名的 `AS` 可以省略。

最后，最后在把上面结结果组合一下，就可以用一条 SQL 语句完成求和了。


## 跨多天的问题

还没有好的解决方法


## MYSQL 函数

### 时间函数

+ `Date(date)` ：取时间日期 yyyy-mm-dd
+ `DATEDIFF(date01,date02)`：去两个时间间隔几天
+ `FROM_UNIXTIME(1111111)`：timestamp 转为 yyyy-mm-dd HH:MM:SS
+ `UNIX_TIMESTAMP('yyyy-mm-dd HH:MM:SS')`： yyyy-mm-dd HH:MM:SS 转为 ：timestamp

## 格式化函数

+ `ROUND(1111.233363,N)`：保留 N 位小数，四舍五入 ROUND(12.567)=12.57
+ `TRUNCATE(222.6666,N)`：保留 N 位小数，截取 TRUNCATE(22.6666,2)=22.66
+ `FLOOR(3.7)` 向下取整  FLOOR(3.7) = 3
+ `CEIL(4.5)`  向上取整  CEIL(4.3) = 5
