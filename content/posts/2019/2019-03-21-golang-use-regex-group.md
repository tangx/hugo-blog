---
date: "2019-03-21T00:00:00Z"
description: golang 正则表达式替换时使用 regex group
keywords: golang
tags:
- golang
title: golang-use-regex-group
---

# golang 使用 regex group 的值

与常用的语言正则不同， golang 使用 `$1` 表示 `regex group`。 而类似 `sed, python` 中常用的是 `\1`

+ golang [playgroud](https://play.golang.org/p/eBsJMyv-25z)

```golang

package main

import (
	"fmt"
	"regexp"
)

func main() {
	re := regexp.MustCompile(`([A-Z])`)
	s := re.ReplaceAllString("UserCreate", ".$1")
	fmt.Println(s) // .User.Create

}

func Test_Regexp(t *testing.T) {
	chars := `('|")`
	str := `"123'abc'456"`
	re := regexp.MustCompile(chars)
	
	s := re.ReplaceAllString(str, `\$1`) // 这里可以使用 ` 反引号
	fmt.Println(s) // \"123\'abc\'456\"

}


// https://stackoverflow.com/questions/43586091/how-golang-replace-string-by-regex-group
```

+ python

```python
import re
name = re.sub(r'([A-Z])', r'.\1', "UserCreate")
print(name) # .User.Create

```