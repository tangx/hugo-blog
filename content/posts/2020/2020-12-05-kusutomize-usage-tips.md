---
date: "2020-12-05T00:00:00Z"
description: 巧用 kustomize 实现 patch ， 实现快速定制化部署
keywords: keyword1, keyword2
tags:
- k8s
- tools
title: k8s 部署工具 kustomize 的实用小技巧
---

# k8s 部署工具 kustomize 的实用小技巧

在 k8s 上的部署， 大多组件都默认提供 helm 方式。 在实际使用中， 常常需要针对不通环境进行差异化配置。 个人觉得， **使用 kustomize 替换在使用和管理上，比直接使用 helm 参数更为清晰** 。 

同时组件在一个大版本下的部署方式通常不会有太大的变化， 没有必要重新维护一套部署文档，其实也不一定有精力这样做。 因此使用 `helm template .` 生成默认部署模版，再使用 kustomize 进行定制化的参数管理是非常方便的。

`kustomize` 作为一款 k8s 部署工具届 *嫁衣神功* ， 偷懒神器。 关于 kustomize 的介绍文章很多，就不再赘述了。 

想要了解使用方法， 可以参考: [官方文档 kustomize API](https://kubectl.docs.kubernetes.io/references/kustomize/)


这里主要将一下笔者日常实用中的几个小技巧。

## 案例分享

使用 helm 生成部署模板并使用 kusutomize 定制化: [kustomize-grafana-loki-stack](https://github.com/tangxin/kustomize-grafana-loki-stack)

## Demo 实践

本文实践基于 `kubectl v1.19.3` 

```bash
kubectl version --client=true
Major:"1", Minor:"19", GitVersion:"v1.19.3", 
```


本文有大量代码和配置， demo 文件已经放在 Github: [tangx/kusutomize-usage-tips-demo](https://github.com/tangx/kusutomize-usage-tips-demo)

**文件结构目录**

```bash
tree .
.
├── Makefile
├── bases
│   ├── dep.yml
│   ├── kustomization.yaml
│   └── svc.yml
└── overlays
    └── online
        ├── configs
        │   └── app.conf
        ├── kustomization.yaml
        └── patches
            └── dep.yml

5 directories, 7 files
```

## 重要且常用的 API

### bases

`bases`: 模版引用， 他人结果原始文档， helm 渲染结果。

1. **注意**: 虽然官方 api 上说 `bases` 是即将被废弃的接口。 但到 `kubectl 1.19.3` 为止， **引用`只能`使用 bases**。

```yaml
# kustomization.yaml

bases:
  - ../../bases
```

### patch

`patch`: 打补丁， 替换已有配置， 或新增配置

1. **注意**: 由于需要锚定被 patch 的对象， 因此 patch 文件 的 yaml 树结构与需要被管理的一致。
2. **建议**: 使用 `patchesStrategicMerge` , 使用文件描述， 因此需要变更的结果最直观。


```yaml
# kustomization.yaml
patchesStrategicMerge:
  - patches/dep.yml
```


```yaml
# patches/dep.yml
--- 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-demo
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: nginx
        resources:
          limits:
            cpu: 1
            memory: 1Gi
      nodeSelector:
        node-env: online

```

### image

`image`: 镜像替换。 使用本地镜像或加速镜像镜像仓库。 
 
1. **tips** : 与 patch 结合 **套娃** 最好用。


```yaml
# kustomization.yaml

images:
  - name: tangx/nginx
    newName: cr.aliyun.com/nginx
    newTag: latest
```

### generate

`generator`: 渲染工具， secret 和 configmap 使用方式一致

1. `secretGenerator` : 渲染 secret 对象
2. `configMapGenerator`: 渲染 configmap 对象
3. `generatorOptions` : 渲染规则


```yaml
# kustomization.yaml

generatorOptions:
  disableNameSuffixHash: true

secretGenerator:
  - name: app-secret
    files:
      - app.cfg=configs/app.conf
      - configs/app.conf
  - name: mysql-secret
    literals:
      - MYSQL_PASSWD=root123
      
configMapGenerator:
  - name: app-config
    files:
      - app.cfg=configs/app.conf
      - configs/app.conf
```

### 执行结果 

使用 `kubectl` 工具直接管理 **渲染/部署/删除** kustomize 文档

```bash
# dryrun
kubectl kustomize overlays/online

# apply
kubectl apply -k overlays/online

# deletd
kubectl delete -k overlays/online

```

**渲染结果**

```yaml
# kubectl kustomize overlays/online

---

apiVersion: v1
data:
  app.cfg: |
    # Uncomment the next line to enable TCP/IP SYN cookies
    # See http://lwn.net/Articles/277146/
    # Note: This may impact IPv6 TCP sessions too
    #net.ipv4.tcp_syncookies=1

    # Uncomment the next line to enable packet forwarding for IPv4
    net.ipv4.ip_forward=1
  app.conf: |
    # Uncomment the next line to enable TCP/IP SYN cookies
    # See http://lwn.net/Articles/277146/
    # Note: This may impact IPv6 TCP sessions too
    #net.ipv4.tcp_syncookies=1

    # Uncomment the next line to enable packet forwarding for IPv4
    net.ipv4.ip_forward=1
kind: ConfigMap
metadata:
  name: app-config
---
apiVersion: v1
data:
  app.cfg: IyBVbmNvbW1lbnQgdGhlIG5leHQgbGluZSB0byBlbmFibGUgVENQL0lQIFNZTiBjb29raWVzCiMgU2VlIGh0dHA6Ly9sd24ubmV0L0FydGljbGVzLzI3NzE0Ni8KIyBOb3RlOiBUaGlzIG1heSBpbXBhY3QgSVB2NiBUQ1Agc2Vzc2lvbnMgdG9vCiNuZXQuaXB2NC50Y3Bfc3luY29va2llcz0xCgojIFVuY29tbWVudCB0aGUgbmV4dCBsaW5lIHRvIGVuYWJsZSBwYWNrZXQgZm9yd2FyZGluZyBmb3IgSVB2NApuZXQuaXB2NC5pcF9mb3J3YXJkPTEK
  app.conf: IyBVbmNvbW1lbnQgdGhlIG5leHQgbGluZSB0byBlbmFibGUgVENQL0lQIFNZTiBjb29raWVzCiMgU2VlIGh0dHA6Ly9sd24ubmV0L0FydGljbGVzLzI3NzE0Ni8KIyBOb3RlOiBUaGlzIG1heSBpbXBhY3QgSVB2NiBUQ1Agc2Vzc2lvbnMgdG9vCiNuZXQuaXB2NC50Y3Bfc3luY29va2llcz0xCgojIFVuY29tbWVudCB0aGUgbmV4dCBsaW5lIHRvIGVuYWJsZSBwYWNrZXQgZm9yd2FyZGluZyBmb3IgSVB2NApuZXQuaXB2NC5pcF9mb3J3YXJkPTEK
kind: Secret
metadata:
  name: app-secret
type: Opaque
---
apiVersion: v1
data:
  MYSQL_PASSWD: cm9vdDEyMw==
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
---
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: nginx-demo
  name: nginx-demo
spec:
  ports:
  - name: 80-80
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx-demo
  type: ClusterIP
status: null
---
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: nginx-demo
  name: nginx-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-demo
  strategy: {}
  template:
    metadata:
      labels:
        app: nginx-demo
    spec:
      containers:
      - image: cr.aliyun.com/nginx:latest
        name: nginx
        resources:
          limits:
            cpu: 1
            memory: 1Gi
          requests:
            cpu: 1
            memory: 1Gi
      nodeSelector:
        node-env: online
```