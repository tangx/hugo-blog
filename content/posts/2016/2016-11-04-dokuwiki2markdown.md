---
date: "2016-11-04T00:00:00Z"
description: shell脚本 将dokuwiki转为markdown 包含部分插件
keywords: shell, script, doku, markdown
tags:
- shell
- blog
title: dokuwiki语法转markdown语法
---

亚马逊的免费网站要到期了。回顾了一下，这一年根本没有写什么东西，网站也基本没人访问。EC2除了搭建了一个SS楼梯之外也没有其他的作用。因此也没有继续折腾。


之前的doku经过几次插件折腾，发现创建文章的初始状态完全靠doku系统生成的缓存记录。之前本来打算把网站图片放到七牛这类空间之中，只备份保存文章目录。不过由于doku的缓存特性，迁移后的文件时间全部全部改变了。

因此这次换上了 Jekyll + Github Pages 。主要原因有几点：
+ 不用管服务器了
+ 文件创建时间由文件名确定了
+ 支持markdown

----

## doku2markdown

这个脚本实现了大部分 doku 语法转 markdown 语法。也支持一些 doku 插件的语法。

doku 的表格语法与 markdown 类似，但markdown 多一个标题栏。目前还没比较好的判断方式，表格转换暂时没有时间。

取消 DOKU_PAGE 的注释，填写正确的 dokuwiki 文章路径

```bash

#!/bin/bash
#
# 2016-11-04 
# doku2markdown.sh
#
# 将dokuwiki标签替换成 markdown 标签
#


# DOKU_PAGE=$PATH/pages

[ "X$DOKU_PAGE" != "X" ] && cd $DOKU_PAGE

find ./ -type f  -name "*.txt"| xargs dos2unix  > /dev/null

# 转换标题
find ./ -type f  -name "*.txt" | xargs sed -i -e 's/^======/#/' -e 's/======$//'
find ./ -type f  -name "*.txt" | xargs sed -i -e 's/^=====/##/' -e 's/=====$//'
find ./ -type f  -name "*.txt" | xargs sed -i -e 's/^====/###/' -e 's/====$//'
find ./ -type f  -name "*.txt" | xargs sed -i -e 's/^===/####/' -e 's/===$//'
find ./ -type f  -name "*.txt" | xargs sed -i -e 's/^==/#####/' -e 's/==$//'
find ./ -type f  -name "*.txt" | xargs sed -i -e 's/^=/######/' -e 's/=$//'

# 转换代码
find ./ -type f  -name "*.txt" |xargs sed -i 's/<sxh \([a-zA-Z0-9]*\).*/\n```\1/'
find ./ -type f  -name "*.txt" | xargs sed -i 's/<sxh>/\n```bash/' 
find ./ -type f  -name "*.txt" | xargs sed -i 's/<\/sxh>/```\n/' 

# 转换横线
find ./ -type f -name "*.txt" | xargs sed -i 's/----/\n----/p'


# 2016-11-04

# 删除 字体 <fs> 标签
find ./ -type f |xargs sed -i -e 's#</fs>##' -e 's#<fs.*>##'   
find ./ -type f |xargs sed -i -e 's#</fc>##' -e 's#<fc.*>##'   

# 删除颜色 <color> 标签
find ./ -type f |xargs sed -i -e 's#</color>##' -e 's#<color.*>##'   

# 删除标签
find ./ -type f |xargs sed -i  -e 's#\\##g'

# 替换代码区间
find ./ -type f |xargs sed -i -e 's#</sxh>#```#' -e 's#<sxh bash.*>#```bash#' 
find ./ -type f |xargs sed -i -e 's#</sxh>#```#' -e 's#<sxh>#```bash#' 
find ./ -type f |xargs sed -i -e 's#</sxh>#```#' -e 's#<sxh python.*>#```python#' 
find ./ -type f |xargs sed -i -e 's#</sxh>#```#' -e 's#<sxh php.*>#```php#' 
find ./ -type f |xargs sed -i -e 's#</sxh>#```#' -e 's#<sxh sql.*>#```sql#' 
# 增加空行
find ./ -type f |xargs sed -i -e 's/```.*/\n&\n/'

# 删除TAG 标签
find ./ -type f |xargs sed -i -e 's#{{tag.*}}##' 


# 替换超级链接
find ./ -type f |xargs sed -i -e 's#\[\[\(.*\)|\(.*\)\]\] *|#[\2](\1)|#g'
find ./ -type f |xargs sed -i -e 's#\[\[\(.*\)|\(.*\)\]\]#[\2](\1)#g'

```

[doku2markdown on github 下载 ]( https://raw.githubusercontent.com/octowhale/bash-scripts/master/tools/doku2markdown.sh )

