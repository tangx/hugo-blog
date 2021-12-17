---
date: "2017-10-24T00:00:00Z"
description: MYSQL 导出用户权限脚本
keywords: mysql
tags:
- mysql
title: MYSQL 导出用户权限脚本
---

# MYSQL 导出用户权限脚本

分享一个抄来的 [mysql 备份权限的脚本](/attachments/2017/dump_grants.sh) 。这个脚本最大的好处是通用，不用像之前那样备份 `mysql.user` 表而造成在不同 mysql 实例之间造成不必要的问题。


```bash
#!/bin/bash
#Function export user privileges
source /etc/profile
pwd=your_password

MYSQL_AUTH=" -uroot -p${pwd} -h127.0.0.1 --port=3306 "
expgrants()
{
  mysql -B ${MYSQL_AUTH} -N $@ -e "SELECT CONCAT('SHOW GRANTS FOR ''', user, '''@''', host, ''';') AS query FROM mysql.user" | mysql ${MYSQL_AUTH} $@ | sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/-- \1 /;/--/{x;p;x;}'
}
expgrants > ./grants.sql

```

+ http://www.cnblogs.com/huangmr0811/p/5570994.html
