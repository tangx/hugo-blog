#!/bin/bash  
#Function export user privileges 
source /etc/profile
pwd=xxxxxxxx 

MYSQL_AUTH=" -uroot -p${pwd} -h127.0.0.1 --port=3306 "
expgrants()  
{  
  mysql -B -u'root' -p${pwd} -N $@ -e "SELECT CONCAT('SHOW GRANTS FOR ''', user, '''@''', host, ''';') AS query FROM mysql.user" | mysql -u'root' -p${pwd} $@ | sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/-- \1 /;/--/{x;p;x;}'  
} 
expgrants > ./grants.sql

