---
date: "2021-12-15T00:00:00Z"
description: gorm 数据库表模型声明笔记
featuredImagePreview: /assets/topic/db.png
keywords: keyword1, keyword2
tags:
- gorm
title: gorm 数据库表模型声明 - 基础
typora-root-url: ../../
---

# gorm 数据库表模型声明 - 基础


## 链接数据库

```go
import (
  "gorm.io/driver/mysql"
  "gorm.io/gorm"
)

func main() {
  // refer https://github.com/go-sql-driver/mysql#dsn-data-source-name for details
  dsn := "user:pass@tcp(127.0.0.1:3306)/dbname?charset=utf8mb4&parseTime=True&loc=Local"
  db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
}
```

## 常用字段类型与 `gorm` 默认字段类型

`varchar, int, datetime, timestamp`

表定义如下

```go
type Author struct {
	gorm.Model
	Name     string
	Password string
}
```

auto migrate 后， 可以看到 `name, password` 默认使用的是 `longtext` 类型。

```sql
show create table authors;

CREATE TABLE `authors` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `name` longtext,
  `password` longtext,
  PRIMARY KEY (`id`),
  KEY `idx_authors_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4

```


## 声明表结构

> 官方文档: https://gorm.io/docs/models.html#Fields-Tags

声明 mysql 表结构时， 遵从一下原则

1. 使用 `gorm` tag
2. tag 中多个字段以 `分号 ;` 分割。
3. 字段内部以 `冒号 :` 分割。

```go
type Author struct {
	gorm.Model

	Name     string `gorm:"index;type:varchar(32);comment:用户昵称"`
	Password string `gorm:"type:varchar(32);comment:用户密码"`
}
```


## 外键声明

> 官方文档:
> 
> 1. https://gorm.io/docs/associations.html#tags
> 2. https://gorm.io/docs/belongs_to.html#Override-Foreign-Key

```go
type Post struct {
	gorm.Model

	Title    string `gorm:"type:varchar(128);index"`
	Content  string `gorm:"longtext"`
	AuthorID int    `gorm:"bigint"`  // 外键字段
	Author   Author `gorm:"foreignKey:AuthorID"`  // 外键关联的表结构, foreign key 指定关联字段
}
```


## 设置表属

> https://jasperxu.com/gorm-zh/database.html#dbc
