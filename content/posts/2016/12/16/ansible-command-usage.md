---
date: "2016-12-16T00:00:00Z"
description: ansible 命令翻译和使用示例
keywords: ansible, command, zhcn
tags:
- ansible
title: ansible 命令及示例
---

# ansible 命令帮助文档

```bash
# ansible -h
Usage: ansible <host-pattern> [options]

Options:
  -a MODULE_ARGS, --args=MODULE_ARGS 
                        模块参数
  --ask-vault-pass      ask for vault password
  -B SECONDS, --background=SECONDS
                        run asynchronously, failing after X seconds
                        (default=N/A)
  -C, --check           不执行任何改变；但是会预判会发生什么改变
                        don't make any changes; instead, try to predict some
                        of the changes that may occur
                        
  -D, --diff            when changing (small) files and templates, show the
                        differences in those files; works great with --check
                        当更改了 files 或 templates 时，显示文件变更类容；
                        与 --check 一起使用
                        
  -e EXTRA_VARS, --extra-vars=EXTRA_VARS
                        set additional variables as key=value or YAML/JSON
                        设置额外的变量， 例如 key=value 或者 YAML/JSON
                        
  -f FORKS, --forks=FORKS
                        specify number of parallel processes to use
                        (default=5)
                        指定并行线程数量（默认为 5 ）
                        
  -h, --help            show this help message and exit
                        显示帮助
                        
  -i INVENTORY, --inventory-file=INVENTORY
                        specify inventory host path
                        (default=/etc/ansible/hosts) or comma separated host
                        list.
                        指定 inventory host 文件路径（默认为 /etc/ansible/hosts ）
                        或者指定使用逗号分割的 host 列表
                        
  -l SUBSET, --limit=SUBSET
                        further limit selected hosts to an additional pattern
                        指定 host 执行命令
                        
  --list-hosts          outputs a list of matching hosts; does not execute
                        anything else
                        打印必配的主机列表；不会执行其他任何操作

  -m MODULE_NAME, --module-name=MODULE_NAME
                        module name to execute (default=command)
                        将被执行的模块名称（默认为 command，即使用系统命令）
                        
  -M MODULE_PATH, --module-path=MODULE_PATH
                        specify path(s) to module library (default=None)
                        指定模块库的路径，默认为 None
                        
  --new-vault-password-file=NEW_VAULT_PASSWORD_FILE
                        new vault password file for rekey
                        
  -o, --one-line        condense output
                        压缩输出结果
                        
  --output=OUTPUT_FILE  output file name for encrypt or decrypt; use - for
                        stdout
                        指定 output 文件名用于加密或解密； 使用 - 表示标准输出。
                        
  -P POLL_INTERVAL, --poll=POLL_INTERVAL
                        set the poll interval if using -B (default=15)
                        
  --syntax-check        perform a syntax check on the playbook, but do not
                        execute it
                        在 playbook 上执行参数检查，但不执行
                        
  -t TREE, --tree=TREE  log output to this directory
                        
  --vault-password-file=VAULT_PASSWORD_FILE
                        vault password file
                        
  -v, --verbose         verbose mode (-vvv for more, -vvvv to enable
                        connection debugging)
                        
  --version             show program's version number and exit

  Connection Options:
    control as whom and how to connect to hosts

    -k, --ask-pass      ask for connection password
                        手动输入密码
                        
    --private-key=PRIVATE_KEY_FILE, --key-file=PRIVATE_KEY_FILE
                        use this file to authenticate the connection
                        使用证书连接登录
                        
    -u REMOTE_USER, --user=REMOTE_USER
                        connect as this user (default=None)
                        指定连接用户
                        
    -c CONNECTION, --connection=CONNECTION
                        connection type to use (default=smart)
                        指定连接使用的类型（默认为 smart ：有则用 ssh，没有则使用 paramiko ）。 
                        
    -T TIMEOUT, --timeout=TIMEOUT
                        override the connection timeout in seconds
                        (default=10)
                        
    --ssh-common-args=SSH_COMMON_ARGS
                        specify common arguments to pass to sftp/scp/ssh (e.g.
                        ProxyCommand)
                        为 sftp/scp/ssh 指定通用参数（ e.g. ProxyCommand ）
                        
    --sftp-extra-args=SFTP_EXTRA_ARGS
                        specify extra arguments to pass to sftp only (e.g. -f,
                        -l)
                        只为 sftp 指定额外参数（ e.g. -f, -l ）
                        
    --scp-extra-args=SCP_EXTRA_ARGS
                        specify extra arguments to pass to scp only (e.g. -l)
                        只为 scp 指定额外参数（ e.g. -l ）
                        
    --ssh-extra-args=SSH_EXTRA_ARGS
                        specify extra arguments to pass to ssh only (e.g. -R)
                        只为 ssh 指定额外参数（ e.g. -R ）

  Privilege Escalation Options:
  提升权限选项：
  
    control how and which user you become as on target hosts

    -s, --sudo          run operations with sudo (nopasswd) (deprecated, use
                        become)
                        使用 sudo 执行操作（ nopasswd ）（不建议使用，使用 become 替代）
                        
    -U SUDO_USER, --sudo-user=SUDO_USER
                        desired sudo user (default=root) (deprecated, use
                        become)
                        指定 sudo user （默认 root ） （不建议使用，使用 become 替代）
    -S, --su            run operations with su (deprecated, use become)
                        使用 su 执行命令（不建议，使用 become 替代）
                        
    -R SU_USER, --su-user=SU_USER
                        run operations with su as this user (default=root)
                        (deprecated, use become)
                        指定 user 使用 su 执行命令（默认为root）
                        （不建议， 使用 become 替代）
                        
    -b, --become        run operations with become (does not imply password
                        prompting)
                        使用 become 执行命令。  (does not imply password
                        prompting)
                        
    --become-method=BECOME_METHOD
                        privilege escalation method to use (default=sudo),
                        valid choices: [ sudo | su | pbrun | pfexec | doas |
                        dzdo | ksu ]
                        指定提权使用的方法（默认为 sudo ）
                        有效选项为： [ sudo | su | pbrun | pfexec | doas | dzdo | ksu ]
                        
    --become-user=BECOME_USER
                        run operations as this user (default=root)
                        指定执行命令使用的用户（默认为 root ）
                        
    --ask-sudo-pass     ask for sudo password (deprecated, use become)
                        使用 sudo 时输入密码（不推荐，使用 become 替代）
                        
    --ask-su-pass       ask for su password (deprecated, use become)
                        使用 su 时输入密码（不推荐，使用 become 替代）
                        
    -K, --ask-become-pass
                        ask for privilege escalation password
                        提权时输入密码
```

## 范例

### `-m module -a module_args`

```bash

# 这里的 ping 实际上是 ansible 的模块，而非系统的 ping 命令。
$ ansible vbox10 -m ping
vbox10 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}



# "-m command" 为默认模块参数。可以省略直接使用 "-a module_args"
# 如果 module_args 参数之间有空格，需要使用双引号隔开。如果为单字，可以不使用引号。
$ ansible vbox10 -m command -a "ls /tmp"
vbox10 | SUCCESS | rc=0 >>
ansible_khzcSl
tmpDnHzgV

$ ansible vbox10 -a "ls /tmp" 
vbox10 | SUCCESS | rc=0 >>
ansible_khzcSl
tmpDnHzgVtmpt33HCq

```
### `--list-hosts`

```bash

$ ansible all --list-hosts
hosts (4):
192.168.56.10
192.168.56.22
vbox10
testserver

```

### `--limit `

```bash

$ cat ./ansible_install_centos68.retry
vbox10

#

$ ansible-playbook ansible_install_centos68.yml --limit @./ansible_install_centos68.retry
[DEPRECATION WARNING]: Instead of sudo/sudo_user, use become/become_user and make sure become_method is 'sudo' (default).
This feature will be 
removed in a future release. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.

PLAY [ansible installation on CentOS68 via yum] ********************************

...

PLAY RECAP *********************************************************************
vbox10                     : ok=4    changed=1    unreachable=0    failed=0   

```