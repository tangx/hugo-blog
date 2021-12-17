---
date: "2016-12-30T00:00:00Z"
description: Mysql 5.6 与5.7 密码权限问题
keywords: keyword1, keyword2
tags:
- mysql
title: Mysql 5.6 与5.7 密码权限问题
---


# Mysql 5.6 与5.7 密码权限问题

在 5.6 和 5.7 中，Mysql 加强了密码的使用。
+ Mysql第一次启动的时候，会初始化一个随机的复杂密码，保存在 `/var/log/mysqld.log`
+ 不再接受简单密码。即复杂密码为： `大小写、数字、符号` 的组合。
+ 在命令行中，不能直接使用 `mysql -u$USER -p$PASSWORD` 的方式了


## 在 bash script 中使用 mysql

[如何在 bash script 中使用 mysql 密码 - stackoverflow.com 讨论](http://stackoverflow.com/questions/20751352/suppress-warning-messages-using-mysql-from-within-terminal-but-password-written)


### 使用 client 配置

在 `/etc/my.cnf` 中配置 `[client]` 区块

或者，使用 `--default-extra-file=/path/to/config.cnf` 

```bash
mysql --defaults-extra-file=/path/to/config.cnf -e "statement;"
mysqldump --defaults-extra-file=/path/to/config.cnf -e "statement;"


# config.cnf 格式如下
[client]
user = whatever
password = whatever
host = whatever
```

不过 `--default-extra-file=/path/to/config.cnf` 必须为命令行的第一个参数，否则会报错。例如，`mysqldump: unknown variable 'defaults-extra-file`


### 使用 mysql_config_editor 和 login-path

在 5.6.x 中，避免 WARNING 消息的方式是使用 `mysql_confg_editor` 工具。

```bash
# 首先在使用 mysql_config_editor 设置一个帐号别名，
# 这样密码会被加密保存在 home/myshellusername/.mylogin.cnf
mysql_config_editor set --login-path=local --host=localhost --user=username --password

# 使用如下命令 
mysql --login-path=local  -e "statement"
mysqldump --login-path=local my_database | gzip > db_backup.tar.gz

# 而不再使用
# mysql -u username -p pass -e "statement"
mysqldump -u db_user -pInsecurePassword my_database | gzip > db_backup.tar.gz
```



### 前置 MYSQL_PWD

设置 MYSQL_PWD 为环境变量，则命令行的时候，不用在指定密码

```bash
export MYSQL_PWD=xxxxxxxx
mysql -u root -e "statement;"
```

另外，在不 export MYSQL_PWD 的情况下，可以将 MYSQL_PWD 放在命令行最前面，也是可行的。

```bash
MYSQL_PWD=xxxxx mysql -uroot -e"statement;"
```

## 修改初始密码

之前提到了， Mysql 在初次启动的时候会生成一个随机密码，保存在 `/var/log/mysqld.log` 中。
首次进入后，不修改 root 密码的话，所有操作都会被阻挡。

### 修改密码

进入 Mysql 后，可以使用 `UPDATE` 命令修改用户的密码

```sql
-- 注意：5.7 中 password 列已经修改为 authentication_string 了
update mysql.user set authentication_string=PASSWORD('Y0urP@assword');
```

官方更建议使用 `ALERT USER`

```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PWD}' ;
```

#### 命令行修改注意事项

+ 使用**随机密码**时，`ALERT` 授权主机必须为 `localhost`，即使 `127.0.0.1` 也不行。
+ 使用**随机密码**时，在命令行中必须使用 `--connect-expired-password` 参数

如下：

```bash
MYSQL57_ROOT_TMP_PWD=$(grep "A temporary password" /var/log/mysqld.log |awk '{print $NF}')
MYSQL_PWD=${MYSQL57_ROOT_TMP_PWD} mysql -u root --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PWD}' ;"
```

## Mysql 5.7 密码插件 validate_password

[ 复制来源 ](http://blog.itpub.net/29773961/viewspace-2077579/)

这个 validate_password 密码强度审计插件决定了你设置的密码是否“过于简单”。

```sql
mysql> SHOW VARIABLES LIKE 'vali%';
+--------------------------------------+--------+
| Variable_name                        | Value  |
+--------------------------------------+--------+
| validate_password_dictionary_file    |        |
| validate_password_length             | 8      |
| validate_password_mixed_case_count   | 1      |
| validate_password_number_count       | 1      |
| validate_password_policy             | MEDIUM |
| validate_password_special_char_count | 1      |
+--------------------------------------+--------+
6 rows in set (0.00 sec)
```

MYSQL 5.7初始化后，默认会安装这个插件，若没有安装，则SHOW VARIABLES LIKE 'vali%'则会返回空。
对应参数的value值也为默认值，以下是这些值的解释

+ validate_password_length 8 # 密码的最小长度，此处为8。
+ validate_password_mixed_case_count 1 # 至少要包含小写或大写字母的个数，此处为 1。
+ validate_password_number_count 1 # 至少要包含的数字的个数，此处为 1。
+ validate_password_policy MEDIUM # 强度等级，其中其值可设置为 0、1、2。分别对应：
  + 【0/LOW】：只检查长度。
  + 【1/MEDIUM】：在0等级的基础上多检查数字、大小写、特殊字符。
  + 【2/STRONG】：在1等级的基础上多检查特殊字符字典文件，此处为1。
+ validate_password_special_char_count 1 # 至少要包含的个数字符的个数，此处为 1。

 