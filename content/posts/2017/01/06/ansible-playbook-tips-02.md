---
date: "2017-01-06T00:00:00Z"
description: 在编写 playbook 时的一些小细节
keywords: playbook, tips
tags:
- ansible
title: ansible playbook 注意事项 02
---

# ansible playbook 注意事项 02


参考 [defaults/main.yml](defaults/main.yml)

```bash
# 关于缩进
# 在 yaml 语法中, `-` 表示指代的是一个列表格式, 在字典的 key 缩进的时候不能算在内.
# 
# --------------------------------
# 如下的缩进, 
# server 和 file_name 位于相同层级
# --------------------------------
# - server:
#   file_name: site3
#   listen: 10101
#   server_name: nginx_playbook
#   root: "/tmp/site3"
```

## 字典写法

以下三种写法等价

参考 [main.yml](main.yml)

```bash
# 01 单行写法
file: path=/etc/nginx/{{ item }} state=directory owner=root group=root mode=0755

# 02 换行写法
file: >
      path=/etc/nginx/{{ item }} 
      state=directory 
      owner=root 
      group=root 
      mode=0755
      
# 03 yaml 语法
file:
  path: "/etc/nginx/{{ item }}"
  state: directory 
  owner: root 
  group: root 
  mode: 0755
```

## 变量引用

参考 [main.yml](main.yml)

```bash
# 使用引号将变量括起来. ansible 2.2.0.0
vars:
  redhat_pkg:
  - nginx
  - python
tasks:
  - name: install python
    # yum: name=python
    yum: name={{ item }} state=present
    # github原文中这里测试不通过
    # with_items: redhat_pkg  
    # 使用引号将变量括起来. ansible 2.2.0.0
    with_items: "{{ redhat_pkg }}"
    when: ansible_os_family == "RedHat"
```

## 条件判断

```bash
# 使用 when 进行条件判断
# 使用 and / or 进行条件连接
when: ansible_os_family == "RedHat" and ansible_distribution_major_version == "6"
```

## 使用 root 用户

[become.rst](https://github.com/ansible/ansible/blob/0f4ca877ac91aa4cf56103f967afec65cca629e1/docsite/rst/become.rst)

```bash

# 01 使用 root 用户连接
remote_user: root

# 02 使用普通用户连接并使用 sudo
# REMOTE_USER 需要具有 sudo 权限
# 不在建议使用 sudo 模块, 使用 become 模块替代
remote_user: REMOTE_USER
become: True
# sudo: True

# 03 切换成其他用户执行
become_user: BECOME_USER

```

## jekyll2 语法

[templates/site.j2](templates/site.j2)

[ j2 部分](https://github.com/octowhale/ansible_notebook/tree/master/playbook/nginx_installation_centos6.8) 由于与 github pages 冲突，不能正常转换。 

![2017-01-06-ansible-playbook-tips-02.png](/assets/img/post/2017/2017-01-06-ansible-playbook-tips-02.png)