---
title: "Python3Install"
date: 2021-09-28T23:49:27+08:00
draft: false
---

CentOS7:

1. 添加仓库 `sudo yum -y install epel-release`
2. 安装IUS软件源 `sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm`
3. 安装python `sudo yum -y install python36u`
4. 安装pip3 `sudo yum -y install python36u-pip`
5. 检查一下安装情况，分别执行命令查看：python3.6 -V ;pip3.6 -V

创建软链接:
`ln -s /usr/bin/python3.6 /usr/bin/python3`
`ln -s /usr/bin/pip3.6 /usr/bin/pip3`

使用方式：在Linux服务器中输入python3，pip3即可（使用python3，是因为python2需要使用，如果为了方便可以`ln -s /usr/bin/python3.6 /usr/bin/py`，这样直接py即可。

--------
单独安装pip包管理工具:
1. 安装依赖源 `yum -y install epel-release` `yum -y install python-pip` 
2. 查看版本 `pip --version`
3. 修改pip源，首先到~/.config/.pip目录下新建（或修改）pip.conf文件. 命令如下：`cd ~ && mkdir .pip;cd .pip && vim pip.conf`

pip换国内源，写入以下内容,最多一个备用url，extra-index-url保留一个即可

``

[global]

index-url=http://mirrors.aliyun.com/pypi/simple/      

#extra-index-url=http://pypi.douban.com/simple

#extra-index-url=https://pypi.tuna.tsinghua.edu.cn/simple/

#extra-index-url=http://pypi.mirrors.ustc.edu.cn/simple/

[install]

trusted-host=mirrors.aliyu.com

``