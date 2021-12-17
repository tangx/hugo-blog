---
date: "2016-11-24T00:00:00Z"
description: python 中使用 shutil 实现文件或目录的复制、删除、移动
keywords: python, shell, libaray, shutil
tags:
- python
- libaray
title: python 中使用 shutil 实现文件或目录的复制、删除、移动
---

# python 中使用 shutil 实现文件或目录的复制、删除、移动

[ shutil 模块](https://docs.python.org/2/library/shutil.html#module-shutil) 提供了多个针对文件或文件集合的高等级操作。 尤其是，文件的复制和删除操作。 对于独立文件的操作， 参考 [ os 模块](https://docs.python.org/2/library/os.html#module-os)


> 警告：
> 即使是更高等级的文件复制功能 ( `shutil.copy(), shutil.copy2()` ) 也不能复制所有文件的元数据(metadata)。
> 在 POSIX 平台上，这意味着文件的属主和用户组会丢失，ACLs也一样。 在 Mac OS 上， 由于没有使用 the resource fork 和其他元数据，因此意味着 resources 会丢失以及文件类型和创建者ID将不会保持原有状态。 在 Windows 上， 文件所有者， ACLs 以及交换数据流(alternate data streams) 不会被复制。


## 文件夹和文件复制

### `shutil.copyfileobj(fsrc, fdst[, length])`

复制类文件(file-like)对象 `fsrc` 的内容到类文件对象 `fdst`。 可选**整数参数** `length`， 指定缓冲区大小。具体而言， `length` 的值为负数，复制操作不会将源数据分块进行复制。 默认的，为了避免不可控制的内存消耗，数据会被分块存入chunk中。 **注意：** 如果 `fsrc` 对象的当前文件位置不为 0 ，则只有从当前文件位置到文件末位的内容会被复制。


### `shutil.copyfile(src, dst)`

复制文件 `src` 的内容（不包含元素据）到文件 `dst` 中。 `dst` 必须为一个完整的目标文件。 如果要将文件复制目标文件夹中，查看 `shutil.copy()` 。 `src` 和 `dst` 不能为同一个文件，否则会[报错](#shutil.Error)。 目标文件位置必须为可写状态，否则会触发 [IOError](https://docs.python.org/2/library/exceptions.html#exceptions.IOError)。 如果 `dst` 已经存在，则会被覆盖。 特别的， 字符设备、块设备和管道不能使用此方法复制。 使用字符串指定`src` 和 `dst` 路径。

### `shutil.copymode(src, dst)`

复制 `src` 的文件**权限位**到 `dst` 。 文件的内容、属主和用户组不会受影响。 使用字符串指定`src` 和 `dst` 路径。

### `shutil.copystat(src, dst)`

复制文件 `src` 的文件**权限位**、**最后访问 access 时间**、**最后修改 modification 时间**和**标识 flags **到 `dst`。文件的内容、属主和用户组不会受影响。 使用字符串指定`src` 和 `dst` 路径。

### `shutil.copy(src, dst)` 

复制文件 `src` 到 `dst` 文件或文件夹中。 如果 `dst` 是文件夹， 则会在文件夹中创建或覆盖一个文件，且该文件与 `src` 的文件名相同。 文件权限位会被复制。使用字符串指定`src` 和 `dst` 路径。

### `shutil.copy2(src, dst)`

与 `shutil.copy()` 类似，另外会同时复制文件的元数据。 实际上，该方法是 `shutil.copy()` 和 `shutil.copystat()` 组合。该方法相当于 Unix 命令的 ` cp -p `。

### `shutil.ignore_patterns(*patterns)`

该工厂函数创建了一个可以被调用的函数， 该函数可以用于 `shutil.copytree()` 的 ** ignore 参数**的值， 以跳过正确匹配的文件和文件夹。 更多参考下面离职。

### `shutil.copytree(src, dst, symlinks=False, ignore=None)`

递归复制整个 `src` 文件夹。 目标文件夹名为 `dst`，不能已经存在；方法会自动创建 `dst` 根文件夹。 文件夹权限和时间通过 `shutil.copystat()` 复制， 单独的文件通过 `shutil.copy2()` 复制。
如果 ` symlinks ` 为真， 源文件夹中的符号链接将会被保留，但是原链接的元数据**不会**被复制。如果值为假或被省略，则链接文件指向文件的内容和元数据复制到新文件夹树中。
如果指定了 `ignore`， 那么他必须是调用队列(callable)，且作为 `shutil.copytree()` 的参数。参数包括文件夹本机及并通过 `os.listdir()` 返回文件夹包含的内容。由于 `shutil.copytree()` 递归复制，因此 `ignore` 会在复制每个子文件夹的时候被调用。 callable必须返回一个由当前文件夹下的文件夹和文件所组成的队列（i.e. a subset of the items in the second argument)； 这些文件夹和文件在复制过程中会被忽略。可以使用 `shutil.ignore_patterns()` 创建callable。

如果发生意外， `shutil.Error()` 返回错误原因。

该源码应该被当作一个示例而不是最终的工具。

> Changed in version 2.3: Error is raised if any exceptions occur during copying, rather than printing a message.
> Changed in version 2.5: Create intermediate directories needed to create dst, rather than raising an error. Copy permissions and times of directories using copystat().
> Changed in version 2.6: Added the ignore argument to be able to influence what is being copied.


## 移动和删除

### `shutil.rmtree(path[, ignore_errors[, onerror]])`

删除整个目录树； `path` 必须指向一个文件夹，但不能是一个指向文件夹的符号链接。 如果 ` ignore_errors ` 值为真， 则删除失败时的信息将会被忽略。如果值为假或省略，那么这些错误将通过 `onerror` 指定的 handler 进行处理； 如果 `onerror` 被省略，则会 raise 一个异常。

如果指定了 `onerror`，则必须是包含三个参数： **function, path 和 excinfo**的 callable 。 第一个参数 ` function ` ， 该函数用于 raise 异常；该函数可以是 `os.path.islink(), os.listdir(), os.remove(), os.rmdir()`。 第二个参数 `path` 为传递给第一个参数的路径。 第三个参数 `excinfo` 为 `sys.exc_info()` 返回的异常信息。 通过 `onerror` raise 的异常不会被捕捉。

> Changed in version 2.6: Explicitly check for path being a symbolic link and raise [OSError](https://docs.python.org/2/library/exceptions.html#exceptions.OSError) in that case.


### `shutil.move(src, dst)`

将一个文件或文件夹从 `src` 移动到 `dst`
如果 `dst` 已存在且为文件夹，则 `src` 将会被移动到 `dst` 内。 如果如 `dst` 存在但不是一个文件夹， 取决于 `os.rename()` 的语义，`dst` 可能会被覆盖。
如果 `dst` 与 `src` 在相同的文件系统下， 则使用 `os.rename()` 。 否认则，将使用 `shutil.copy2()` 复制 `src` 到 `dst` 并删除。

### `shutil.Error ` 

该异常汇集文件操作时 raise 的异常。 例如 `shutil.copytree()`，  the exception argument is a list of 3-tuples (srcname, dstname, exception).