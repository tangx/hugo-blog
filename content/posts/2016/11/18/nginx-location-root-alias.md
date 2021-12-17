---
date: "2016-11-18T00:00:00Z"
description: nginx 子目录路径配置 root 与 alias 的区别
keywords: nginx, alias
tags:
- nginx
title: nginx 子目录路径配置 root 与 alias 的区别
---

# nginx 子目录路径配置 root 与 alias 的区别

最近在nginx上部署日志分析工具awstats时，在配置awstats分析结果可供网页浏览这步时，分析结果页面访问总是404.后来查阅了一些资料，发现是root和alias的用法区别没搞懂导致的，这里特地将这两者区别详尽道来，供大家学习参考。
Nginx其实没有虚拟主机这个说法，因为它本来就是完完全全根据目录来设计并工作的。如果非要给nginx安上一个虚拟目录的说法，那就只有alias比较『像』了。


## 那alias标签和root标签到底有哪些区别呢？

1、alias后跟的指定目录是准确的,并且末尾必须加『/』，否则找不到文件

```
location /c/ {
      alias /a/
}
```

如果访问站点http://location/c访问的就是/a/目录下的站点信息。
2、root后跟的指定目录是上级目录，并且该上级目录下要含有和location后指定名称的同名目录才行，末尾『/』加不加无所谓。

```
location /c/ {
      root /a/
}
```

如果访问站点http://location/c访问的就是/a/c目录下的站点信息。

3、一般情况下，在location /中配置root，在location /other中配置alias是一个好习惯。

其他乱七八糟的东西这里就不乱扯了，只要这个几点理解透，日常多操作几下就理解了。


[原文地址](http://nolinux.blog.51cto.com/4824967/1317109)

