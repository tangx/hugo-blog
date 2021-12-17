---
date: "2016-12-30T00:00:00Z"
description: 在编写 playbook 时的一些小细节
keywords: playbook, tips
tags:
- ansible
title: ansible playbook 注意事项 01
---

# ansible playbook 注意事项 01

## notify 触发条件

不能在没有变更系统状态的条件下触发 notify 。
即，此处不能省略 `template` 模块

```
# tasks
- name: Configure ntp file
  template: src=ntp.conf.j2 dest=/etc/ntp.conf
  notify: restart ntpd
  tags: ntp  
```

## 变量文件

通过 `vars_files` 指定变量文件位置

```
- name: install MySQL57
  hosts: mysql-server
  remote_user: root
  
  vars_files:
    - vars/dbserver.yml
    
  roles:
    - db
```

## 模块提示

在编写 playbook 的时候，遇到不知道或不清楚的模块时。可以使用 `command: sys_command_bin args`。
如果 ansible 有合适的模块会在 play 运行的输出中提示。例如：

+ [WARNING]: Consider using unarchive module rather than running tar
+ [WARNING]: Consider using get_url or uri module rather than running wget

```
- name: Unarchive gogs package {{ gogs_package_version }}
  unarchive: src="{{ gogs_package_store_dir }}/{{ gogs_package_version }}" dest={{ gogs_package_store_dir }} creates="{{ gogs_package_store_dir }}/gogs" copy=no  
  # TASK [gogs : Unarchive gogs package gogs_v0.9.113_linux_amd64.tar.gz] **********
  # skipping: [gogs-server]
  
  # 这里是提示
  # command: tar zxf "{{ gogs_package_store_dir }}/{{ gogs_package_version }}" -C {{ gogs_package_store_dir }}
  # [WARNING]: Consider using unarchive module rather than running tar

```

参考[Ansible 官网文档](http://docs.ansible.com/ansible/file_module.html)，这里给出了现在所有的模块的用法。
由于[Ansible 官网文档](http://docs.ansible.com/ansible/file_module.html)并不提供搜索功能。可以访问 [Ansible 在 Github](https://github.com/ansible/ansible/blob/devel/docsite/rst/index.rst) 上的仓库，使用 Github 提供的搜索功能查找关键字。


## 进入目录

`chdir`

```

- name: Change dir and run command
  command: chdir /path/to/dir ls -al

```

## 变量与引号

两个变量链接的时候，需要使用双引号括起来。
部分变量（如 url）在使用的时候，可能需要使用双引号括起来。

```
- name: Download gogs package {{ gogs_package_version }}
  # command: wget -c http://7d9nal.com2.z0.glb.qiniucdn.com/gogs_v0.9.113_linux_amd64.tar.gz -O /opt/gogs_v0.9.113_linux_amd64.tar.gz
  # [WARNING]: Consider using get_url or uri module rather than running wget
  get_url: 
    url: "{{ gogs_package_url }}"
    dest: "{{ gogs_package_store_dir }}/{{ gogs_package_version }}"
```

## 错误

### yum 循环错误

使用 `with_items` 安装 Mysql5.7 组件 `mysql-community-server` 与 `mysql-community-devel` 的时候
ansible 报错：`one of the following is required: name,list`。 
使用了单引号或双赢好，但是依旧报错。

```

# - name: Install mysql-community-server mysql-community-devel of mysql 
  # yum: name= {{ item }} state=installed
  # with_items:
    # - 'mysql-community-server'
    # - 'mysql-community-devel'
  # tags: mysql
  
# NOTE: there is something strange here
#   mysql-community-server mysql-community-devel can not be installed with with_items
#   It will occur a mistake like follow. 
#   Maybe something wrong with the dash(-) symbal. 

# TASK [db : Install mysql-community-server mysql-community-devel of mysql] ******
# failed: [mysql-server] (item=mysql-community-server) => {"failed": true, "item": "mysql-community-server", "msg": "one of the following is required: name,list"}
# failed: [mysql-server] (item=mysql-community-devel) => {"failed": true, "item": "mysql-community-devel", "msg": "one of the following is required: name,list"}

```
