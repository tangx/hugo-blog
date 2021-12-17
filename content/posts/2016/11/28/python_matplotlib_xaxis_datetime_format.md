---
date: "2016-11-28T00:00:00Z"
description: 在 python 中使用 matplatlib 画图，并格式化坐标轴时间格式，始终显示更加合理
keywords: python, 画图, 格式化
tags:
- python
title: python matplatlib 格式化坐标轴时间 datetime
---

# python matplatlib 格式化坐标轴时间 datetime

使用 `matplatlib.pyploy` 可以非常方便的将**数组**转换成时间。但是，如果是时间 `datetime.datetime()` 作为坐标轴，如果不对时间进行优化，将会显得非常紧凑。

对坐标轴时间进行优化，用到的库为 `matplatlib.dates`。主要代码如下

```python
import datetime
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
# from matplotlib.dates import YearLocator, MonthLocator, DayLocator
# from matplotlib.dates import drange, DateLocator, DateFormatter
# from matplotlib.dates import HourLocator, MinuteLocator, SecondLocator

def gen_image_2(l):
    # 格式化刻度单位
    # years=mdates.YearLocator()
    # months=mdates.MonthLocator()
    # days=mdates.DayLocator()
    hours = mdates.HourLocator()
    minutes = mdates.MinuteLocator()
    seconds = mdates.SecondLocator()

    # dateFmt = mdates.DateFormatter('%Y-%m-%d %H:%M')
    # dateFmt = mdates.DateFormatter('%Y-%m-%d')
    dateFmt = mdates.DateFormatter('%H:%M')  # 显示格式化后的结果

    if len(l) != 2:
        return False

    x = l[0]
    y = l[1]

    fig, ax = plt.subplots()    # 获得设置方法
    # format the ticks
    ax.xaxis.set_major_locator(hours)  # 设置主要刻度
    ax.xaxis.set_minor_locator(minutes)  # 设置次要刻度
    ax.xaxis.set_major_formatter(dateFmt)  # 刻度标志格式

    # 添加图片数据
    # plt.plot_date(dates, y, 'm-', marker='.', linewidth=1)
    plt.plot_date(x, y, '-', marker='.')
    # plt.plot(x, y)


    fig.autofmt_xdate()  # 自动格式化显示方式

    plt.show()  # 显示图片
```

以下部分是用来格式化坐标轴上的刻度的。

## 格式化刻度单位

```python

# 设置方法
fig, ax = plt.subplots()

# 转化刻度单位
# years=mdates.YearLocator()
# months=mdates.MonthLocator()
# days=mdates.DayLocator()
hours = mdates.HourLocator()
minutes = mdates.MinuteLocator()
seconds = mdates.SecondLocator()

# 应用刻度单位
ax.xaxis.set_major_locator(hours)  # 设置主要刻度
ax.xaxis.set_minor_locator(minutes)  # 设置次要刻度
ax.xaxis.set_major_formatter(dateFmt)  # 刻度标志格式
```

## 显示格式化后的结果

```python
# 显示
# dateFmt = mdates.DateFormatter('%Y-%m-%d %H:%M')
# dateFmt = mdates.DateFormatter('%Y-%m-%d')
dateFmt = mdates.DateFormatter('%H:%M')  # 显示格式化后的结果

# 应用
ax.xaxis.set_major_formatter(dateFmt)  # 刻度标志格式
```

## 填充数据

```python
# 添加图片数据
# plt.plot_date(dates, y, 'm-', marker='.', linewidth=1)
plt.plot_date(x, y, '-', marker='.')
# plt.plot(x, y)

```

## 坐标轴刻度显示方式

```python
fig.autofmt_xdate()  # 自动格式化显示方式
```

## 显示或保存图片

```python
plt.show()  # 显示图片
plt.
```

> 注意： `fig.autofmt_xdate()` 必须用在**填充数据**之后
如果不使用 `fig.autofmt_xdate()` 那么坐标轴显示标志会水平与坐标轴。如果使用了，则会斜靠在坐标轴上，这样就可以显示更多的长标志

![figure_1.png](/assets/img/post/2016/2016-11-28-python_matplotlib_xaxis_datetime_format-01.png)

## github 代码托管
[matplatlib API demon](http://matplotlib.org/examples/api/date_demo.html)
[matplot 格式化坐标轴时间表示](https://github.com/octowhale/python/blob/master/python_example/python_matplotlib_xaxis_datetime_format.py)