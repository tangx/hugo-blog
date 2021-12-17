---
date: "2016-11-10T00:00:00Z"
description: ansible 入门
keywords: ansible
tags:
- ansible
title: ansible 入门
---

# ansible 指南

## 本地执行

> https://cloud.tencent.com/developer/ask/28078

```yaml
# 方法1: 
- name: check out a git repository
  local_action: 
    module: git
    repo: git://foosball.example.org/path/to/repo.git
    dest: /local/path

---
# 方法2: 
- name: check out a git repository
  local_action: git
  args:
    repo: git://foosball.example.org/path/to/repo.git
    dest: /local/path
```

## 判断目标状态 / 判断目标是否存在

```yaml
- stat: path=/path/to/something 
    register: p 

# 判断目标是否为文件夹
- debug: msg="Path exists and is a directory" 
    when: p.stat.isdir is defined and p.stat.isdir 

# 判断目标是否为文件夹
- debug: msg="Path exists" 
    when: p.stat.exists

```