---
title: "filebrowser"
date: 2022-05-20T10:06:28+08:00
draft: false
---
# 序章
filebrowser 定位应该算是一款轻量级云盘，全平台通用，当然我肯定是以Linux为主。
# 安装
filebrowser的安装可以说很简单，但是我却卡了很久，排查问题是件很费精力的事情呐。（我的问题是服务器提供商有防火墙，导致端口未开放）  
```curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash```
# 部署
安装完成后，并不能直接食用，还需要一些操作。
```
filebrowser -d /etc/filebrowser.db config init
filebrowser -d /etc/filebrowser.db config set --address 0.0.0.0
filebrowser -d /etc/filebrowser.db config set --port 8088
```
在进行了如上的配置后，就可以启动啦
```
filebrowser -d /etc/filebrowser.db
```
这里对上述命令做一些大白话解析，-d /etc/filebrowser.db 意思是指定数据库的路径，如果直接使用filebrowser启动将会默认在当前执行该命令的路径下生成filebrowser.db，可以认为是做了filebrowser config init操作。

如果上述命令执行过程中有问题，可以检查是否是权限问题导致的，sudo提权。
# 检查端口问题
首先排查是否是本机的防火墙状态，sudo ufw status  
其次去服务器提供商那里看看防火墙状态，简单的方式就是telnet测试。本机使用telnet + ip + port。例如检测8080端口就是 telnet 123.456.789 8080，telnet 123.456.789 22；ip是服务器的ip地址，可以检测该端口是否可以正常访问，通常22端口肯定是开放的，毕竟是ssh端口。如果端口无法访问，则去服务器提供商那里操作下，把防火墙打开。
# 进阶
我们当然不会指望，每次都filebrowser -d /etc/filebrowser.db以这种方式启动，并且服务器重启那不就又得去操作一下？这显然是不能忍受的。我们要让它自动启动。

编写service文件，复制以下内容，简要说明ExecStart=/usr/local/bin/filebrowser -d /etc/filebrowser.db，这个根据你filebrowser的实际位置填写。（另自行查找vim的基本使用）

sudo vim /usr/lib/systemd/system/filebrowser.service
```
[Unit]
Description=File browser
After=network.target

[Service]
ExecStart=/usr/local/bin/filebrowser -d /etc/filebrowser.db

[Install]
WantedBy=multi-user.target
```
这样子就算是大公告成了，然后我们就可以愉快的使用filebrowser了。使用下面的方式启动，停止，查看filebrowser的状态。
```
sudo systemctl start filebrowser
sudo systemctl stop filebrowser
sudo systemctl status filebrowser
#开机启动
sudo systemctl enable filebrowser.service
```
# 尾声
如果你乐意当然还可以设置日志位置：filebrowser -d /etc/filebrowser.db config set --log /var/log/filebrowser.log

添加一个用户：filebrowser -d /etc/filebrowser.db users add 填用户名 填密码 --perm.admin

设置语言环境：filebrowser -d /etc/filebrowser.db config set --locale zh-cn

当然这些也可以在你登录之后，在图形化界面去设置。
# 疑惑
当我一开始在网上查找教程的时候总是能看到下面这种，其实就是另外一种方式罢了，仅供参考。
```
vi /etc/filebrowser/config.json
filebrowser -c config.json
{
　　"port": 8090,
　　"address": "0.0.0.0",
　　"noAuth": false,
　　"password":"12345678",
　　"root":"/data/fbroot",
　　"alternativeReCaptcha": false,
　　"reCaptchaKey": "",
　　"reCaptchaSecret": "",
　　"database":"/etc/filebrowser/filebrowser.db",
　　"log":"/var/log/filebrowser.log",
　　"plugin": "",
　　"baseURL": "/filebrowser",
　　"allowCommands": true,
　　"allowEdit": true,
　　"allowNew": true,
　　"commands": [
　　　　"ls",
　　　　"df"
　　]
}
```
