---
date: "2017-11-05T00:00:00Z"
description: 使用 sshpass 为传递密码
keywords: sshpass, linux
tags:
- linux
title: 使用 sshpass 传递密码
---

# 使用 sshpass 传递密码


## 使用 sshpass 给 ansible 传递密码

```bash
$ sshpass -p 'xxxxxxxx' ansible -i dsgl_domantic.py all -m ping --limit=1x.x.x.x0 -u root --ask-pass
1x.x.x.x0 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```

## 将密码写入命令行中

```bash
sshpass -p 'your_password_string' ssh  58.*.*.197

```

## 将密码写入变量中

```bash
export SSHPASS='your_password_string'
sshpass -e ssh 118.*.*.16
```

## 将密码写入文件中

```bash
echo 'your_password_string' > sshpass.sec

sshpass -f sshpass.sec ssh 118.*.*.16
```