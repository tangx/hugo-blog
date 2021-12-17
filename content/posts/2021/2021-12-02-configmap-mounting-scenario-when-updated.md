---
date: "2021-12-02T00:00:00Z"
description: K8S 中被挂载的 Configmap 发生了变化容器内部会发生什么
image: topic/k8s.png
keywords: k8s, configmap, volume
tags:
- k8s
- configmap
title: K8S 中被挂载的 Configmap 发生了变化容器内部会发生什么
typora-root-url: ../../
---

# K8S 中被挂载的 Configmap 发生了变化容器内部会发生什么



## 1. 使用 env 挂载

被挂载的值不会变

```yaml
      env:
        # 定义环境变量
        - name: PLAYER_INITIAL_LIVES # 请注意这里和 ConfigMap 中的键名是不一样的
          valueFrom:
            configMapKeyRef:
              name: game-demo           # 这个值来自 ConfigMap
              key: player_initial_lives # 需要取值的键
```



## 使用 volumeMounts 挂载目录

在使用 `volumeMounts` 挂载的时候， 根据是否有 subpath 参数， 情况也不一样。



### 2.1 没有 subpath 挂载目录

```yaml
      volumeMounts:
      - name: config
        mountPath: "/config/normal-dir/some-path/"
```

可以看到， 挂载目录时

1. **目标文件** 是一个 **软链接** ， 链接到  `..data` 目录文件中。
2. 而 `..data` 文件本身也是一个 **软链接**  ， 链接到真实目录 `..2021_12_02_03_11_39.450637616`

![image-20211202111242316](/assets/img/post/2021/2021-12-02-configmap-mounting-scenario-when-updated/image-20211202111242316.png)

当 configmap 发生变化的时候， 真实目录将被 k8s 替换。 而 `..data` 也将重新软连接新的真实目录中。

注意在更新 configmap 之后， 真实目录名称已经发生变化， 成为 `..2021_12_02_03_24_10.989932403`

![image-20211202113051097](/assets/img/post/2021/2021-12-02-configmap-mounting-scenario-when-updated/image-20211202113051097.png)

### 2.2 使用 subPath 挂载文件

```yml
      volumeMounts:
      - name: config
        mountPath: "/config/subpath-file/some-path/game.properties"
        subPath: game.properties
```

使用 subPath 挂载文件时， **目标文件** 是 **不是** 一个软链接， 注意与挂载目录时的对比。 而生成是一个 **真实文件** 。  

![image-20211202112449476](/assets/img/post/2021/2021-12-02-configmap-mounting-scenario-when-updated/image-20211202112449476.png)

当 configmap 发生变化的时候， 该文件 **不会发生任何变化** 。



### 2.3 使用 subPath 挂载目录

```yaml
      volumeMounts:
      - name: config
        mountPath: "/config/subpath-dir/some-path/"
        subPath: "."
```

这种情况行为情况与 [2.1 没有 subpath 挂载目录](#2.1 没有 subpath 挂载目录)  一致。



## 3. 挂载目录与挂载文件有什么不同

如果熟悉 linux 中的 mount 原理， 就很容易理解。

```yaml
      volumeMounts:
      - name: config
        mountPath: "/var/spool/cron/crontabs/game.properties"
        subPath: game.properties
```

1. **挂载目录** 到 **目标路径（目录）**，  将直接 **隐藏** 目标路径的目录， 显示挂载目录的文件
2. **挂载文件** 到 **目标路径（文件）** ， 将直接 **隐藏** 目标路径中文件， 显示挂载的文件。 而由于作用域比目录小， 所以挂载文件能与目标目录中的其他文件 **共存** 。

![image-20211202114131556](/assets/img/post/2021/2021-12-02-configmap-mounting-scenario-when-updated/image-20211202114131556.png)

也不会影响到 **目标目录** 原有的属性。

![image-20211202114244432](/assets/img/post/2021/2021-12-02-configmap-mounting-scenario-when-updated/image-20211202114244432.png)





## 4. 扩展: 使用 `docker -v` 挂载目录和文件到容器中 



这个也是为什么使用 docker 命令 **挂载node文件** 和 **挂载node目录** 到容器中后， 在 node 上修改文件是否会影响到容器内部的原因一样。

```bash
docker run -it --rm \
		-v /node/path/file:/container/path1/file \
		-v /node/path/:/container/path2/ \
		alpine sh
```



其根本原因是： 被挂载 **文件或目录** 的 inode 发生了之后， 是否能继续反馈到容器中。

使用命令创建 **硬连接** 

```
ln -f demo.txt mode.txt
```

![image-20211202120150888](/assets/img/post/2021/2021-12-02-configmap-mounting-scenario-when-updated/image-20211202120150888.png)

可以看到二者的 inode 是一样的。

1. 使用 `vi` 编辑 `demo.txt` 后， 二者 inode 依旧一样， 因此 demo.txt 的变更也会在 mode.txt 中看到， 因为他们还是一个文件。

![image-20211202120437282](/assets/img/post/2021/2021-12-02-configmap-mounting-scenario-when-updated/image-20211202120437282.png)



2. 但是使用 `sed` 编辑 `demo.txt` 后， 二者 inode 不一样了， 因此 demo.txt 和 mode.txt 其实是两个文件了。 

![image-20211202120445113](/assets/img/post/2021/2021-12-02-configmap-mounting-scenario-when-updated/image-20211202120445113.png)

因此二者的内容自然就不一样了。



## 5. 参考资源

1. Configmap : https://kubernetes.io/zh/docs/concepts/configuration/configmap/
2. Volume: https://kubernetes.io/zh/docs/concepts/storage/volumes/

