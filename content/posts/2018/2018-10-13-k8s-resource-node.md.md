---
date: "2018-10-13T00:00:00Z"
description: k8s node 节点介绍
keywords: k8s, kubernetes
tags:
- k8s
title: k8s node 节点
---

# k8s node 节点介绍

node 是 k8s 的工作节点， cpu, memory 的提供者。 上面运行这实际工作的 pod。

node 的服务包括 container 环境、 kubelet 和 kube-proxy。


## 使用 kubectl 管理 node

基础语法为 : `kubectl flag node <node_name> `


### kubectl cordon / uncordon


```bash
# 驱逐
kubectl cordon node <node_name>
# 恢复
kubectl uncordon node <node_name>
```
