---
title: "ssh密钥部署"
date: 2022-02-15T16:28:22+08:00
draft: false
---
# 背景假定
在windows环境下连接远程linux服务器

1. windows下安装Git工具
2. 鼠标右键打开GitBash,输入命令`ssh-keygen`一路回车即可,密钥文件应该生成在当前用户目录.ssh文件夹下.for me:`ssh-keygen -t rsa -C "im.kevinliao@gmail.com"`
3. 拷贝地址到远端Linux服务器`ssh-copy-id -i ~/.ssh/id_rsa.pub root@your_ip_address`,具体ip地址根据实际情况填写
4. 登录服务器`ssh root@your_ip_address`

# 登录之后
1. 为了安全起见建议关闭密码登录,关闭方式修改sshd_config文件： vim /etc/ssh/sshd_config
2. 具体修改参数：PasswordAuthentication no 改为yes
3. 重启sshd服务，使配置生效：`systemctl restart sshd`
