---
date: "2017-11-11T00:00:00Z"
description: filebeat将多行日志视作一样的参数配置
keywords: filebeat, log, es
tags:
- filebeat
- log
title: filebeat将多行日志视作一样的参数配置
---

# filebeat 将多行日志视作一样的参数配置

在 `filebeat` 格式化日志是，可以配置 `pattern` 将多行日志合并成一样。

在配置文件 `filebeat.yml` 中，协同完成这个功能的参数有 `4` 个。

```yaml
  # The regexp Pattern that has to be matched.
  # 设置行的匹配字段
  multiline.pattern: '^[[:space:]]|^[[:alpha:]]'

  # Defines if the pattern set under pattern should be negated or not. Default is false.
  # 设置符合上面匹配条件的的行，是否应该被合并成一条日志。
  # false 为 合并。 true 为不合并
  multiline.negate: false

  # Match can be set to "after" or "before". It is used to define if lines should be append to a pattern
  # that was (not) matched before or after or as long as a pattern is not matched based on negate.
  # Note: After is the equivalent to previous and before is the equivalent to to next in Logstash
  # 设置 符合pattern行 应该被合并到之前不符合pattern 的行，还是之后的行。
  multiline.match: after

  # The maximum number of lines that are combined to one event.
  # In case there are more the max_lines the additional lines are discarded.
  # Default is 500
  # 最大识别多少行。
  multiline.max_lines: 100
```