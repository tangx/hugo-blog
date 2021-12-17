---
date: "2019-04-23T00:00:00Z"
description: 关于 nginx uri 的截取
keywords: nginx, rewite, proxy_pass
tags:
- nginx
- proxy
title: 关于 nginx uri 的截取
---

# 关于 uri 的截取

`location` 中的 `root` 和 `alias`

+ `root` 指令只是将搜索的根设置为 `root` 设定的目录，即不会截断 uri，而是使用原始 uri 跳转该目录下查找文件
+ `alias` 指令则会截断匹配的 uri，然后使用 `alias` 设定的路径加上剩余的 uri 作为子路径进行查找

示例 1： root

```conf
#------------目录结构----------
/www/x1/index.html
/www/x2/index.html

#--------配置-----------------------
index index.html index.php;
location /x/ {
    root "/www/";
}

#-------访问--------------
curl http://localhost/x1/index.html
curl http://localhost/x2/index.html

```

示例 2：alias

```conf
#----------配置-----------------
location /y/z/ {
    alias /www/x1/;
}

#---------访问--------------
curl http://localhost/y/z/index.html

```


**location 中的 proxy_pass 的 uri**

如果 `proxy_pass` 的 url 不带 uri

+ 如果尾部是"/"，则会截断匹配的uri
+ 如果尾部不是"/"，则不会截断匹配的uri
+ 如果proxy_pass的url带uri，则会截断匹配的uri

示例：
```bash
#-------servers配置--------------------
location / {
    echo $uri    #回显请求的uri
}

#--------proxy_pass配置---------------------
location /t1/ { proxy_pass http://servers; }    #正常，不截断
location /t2/ { proxy_pass http://servers/; }    #正常，截断
location /t3  { proxy_pass http://servers; }    #正常，不截断
location /t4  { proxy_pass http://servers/; }    #正常，截断
location /t5/ { proxy_pass http://servers/test/; }    #正常，截断
location /t6/ { proxy_pass http://servers/test; }    #缺"/"，截断
location /t7  { proxy_pass http://servers/test/; }    #含"//"，截断
location /t8  { proxy_pass http://servers/test; }    #正常，截断
#---------访问----------------------
for i in $(seq 6)
do
    url=http://localhost/t$i/doc/index.html
    echo "-----------$url-----------"
    curl url
done

#--------结果---------------------------
----------http://localhost:8080/t1/doc/index.html------------
/t1/doc/index.html

----------http://localhost:8080/t2/doc/index.html------------
/doc/index.html

----------http://localhost:8080/t3/doc/index.html------------
/t3/doc/index.html

----------http://localhost:8080/t4/doc/index.html------------
/doc/index.html

----------http://localhost:8080/t5/doc/index.html------------
/test/doc/index.html

----------http://localhost:8080/t6/doc/index.html------------
/testdoc/index.html

----------http://localhost:8080/t7/doc/index.html------------
/test//doc/index.html

----------http://localhost:8080/t8/doc/index.html------------
/test/doc/index.html
```