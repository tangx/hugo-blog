---
date: "2021-09-02T00:00:00Z"
description: null
keywords: Typora
tags:
- typora
title: typora 定义 github pages 专属配置
typora-root-url: ../../
---



typora ， 可以说一款为 github pages 网站量身定制的软件



## 配置初始目录



在 **配置中** 选择 **General** ， 选择默认打开的目录。 



![image-20210902183911960](/assets/img/post/2021/2021-09-02-typora-borned-for-github-page/image-20210902183911960.png)



## 配置图片路径



众所周知， `Github Pages(Jekyll)`  中， 文章需要放到 `_post` 下， 而资源应该另外创建目录， 如 `assert` 等。 这就造成了普通 **markdown** 编辑器插入图片的不方便。

解决方法如下：

1. 使用图床， 彻底外部独立， 不存在相对路径的问题
2. 放在 `assert` 下面， 但本地又无法预览。



## 解决方法



typora 很好的为我们解决了这个问题。



### 相对路径下的绝对路径

使用 `typora-root-url` 拼接 `md` 文件中图片的绝对路径。

例如, 

在文章 **meta**  加入  `typora-root-url:/User/Abner/Website/typora.io/`

那么在文章中引用图片时使用 **绝对路径**  `![alt](/blog/img/test.png)`  将会被解析成  `![alt](file:///User/Abner/Website/typora.io/blog/img/test.png)` .

配置方式 :  `Format` → `Image` → `Use Image Root Path` 



#### 使用变量

typora 中的全局变量 `${currentPath}` 表示 `md` 文件的位置。 

例如 `/User/Abner/typora.io/post/2021/file.md` 

所以 `${currentPath}/../../../images/2021/file/123123.jpg` 表示 `/User/Abner/typora.io/images/2021/file/123123.jpg`

```
---
typora-root-url: ${currentPath}/../../../
---
```



### 全局图片配置



在全局配置 `Image -> WhenInster` 中， 选择 `custom folder` ， 可以指定插入图片的绝对路径。

![image-20210902185400203](/assets/img/post/2021/2021-09-02-typora-borned-for-github-page/image-20210902185400203.png)



结合之前的 `typora-root-url` 一起使用， 既可以在编辑的时候预览图片， 又能解决发布后的图片路径。

