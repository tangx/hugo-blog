---
date: "2017-08-03T00:00:00Z"
description: some word here
keywords: mysql, database
tags:
- mysql
- database
title: 怎么通过命令行方式向 mysql 数据库导入一个大型备份文件
---

# 怎么通过命令行方式向 mysql 数据库导入一个大型备份文件

接受了一个老项目，有个200多G 的文件需要恢复。里面有有几张记录日志的单表很大，在备份的时候没有使用 `--extended-inster=False` ， 因此，在使用 `mysql database < file.sql` 导入的时候，一不留神进程就死掉了。


google 了很久，最终得到以下答案

> 原文链接 ：  https://cmanios.wordpress.com/2013/03/19/import-a-large-sql-dump-file-to-a-mysql-database-from-command-line/


是通过在 mysql 交互界面中 source 文件的方式导入的。
核心内容是在导入的时候，扩大缓冲空间以及关闭外键检查。导入之后重新恢复检查

### 导入前
```sql
-- You are now in mysql shell. Set network buffer length to a large byte number. The default value may throw errors for such large data files
set global net_buffer_length=1000000;
-- Set maximum allowed packet size to a large byte number.The default value may throw errors for such large data files.
set global max_allowed_packet=1000000000;
-- Disable foreign key checking to avoid delays,errors and unwanted behaviour
SET foreign_key_checks = 0;
SET UNIQUE_CHECKS = 0;
SET AUTOCOMMIT = 0;

```

### 导入后
```sql
-- You are done! Remember to enable foreign key checks when procedure is complete!

SET foreign_key_checks = 1;
SET UNIQUE_CHECKS = 1;
SET AUTOCOMMIT = 1;
```


经过一下封装，最终实现了在 shell 交互界面完成导入。

已经试过，没有问题。


```bash
#!/bin/sh

#

# store start date to a variable
imeron=`date`

echo "Import started: OK"
dumpfile="/home/bob/bobiras.sql"

ddl="set names utf8; "
ddl="$ddl set global net_buffer_length=1000000;"
ddl="$ddl set global max_allowed_packet=1000000000; "
ddl="$ddl SET foreign_key_checks = 0; "
ddl="$ddl SET UNIQUE_CHECKS = 0; "
ddl="$ddl SET AUTOCOMMIT = 0; "
# if your dump file does not create a database, select one
ddl="$ddl USE jetdb; "
ddl="$ddl source $dumpfile; "
ddl="$ddl SET foreign_key_checks = 1; "
ddl="$ddl SET UNIQUE_CHECKS = 1; "
ddl="$ddl SET AUTOCOMMIT = 1; "
ddl="$ddl COMMIT ; "

echo "Import started: OK"

time mysql -h 127.0.0.1 -u root -proot -e "$ddl"

# store end date to a variable
imeron2=`date`

echo "Start import:$imeron"
echo "End import:$imeron2"

```

### 其他一些关于大数据的备份和恢复的讨论

>  https://gxnotes.com/article/78814.html

> https://stackoverflow.com/questions/132902/how-do-i-split-the-output-from-mysqldump-into-smaller-files

> https://stackoverflow.com/questions/13717277/how-can-i-import-a-large-14-gb-mysql-dump-file-into-a-new-mysql-database
