---
title: "samba"
date: 2023-09-27T22:25:23+08:00
draft: false
---
# Samba 服务配置 （Ubuntu22.04)
1. 安装samba
2. 创建用户或者添加用户
3. 配置smb.conf
4. 重启samba

```
sudo apt install samba

sudo adduser kevin

sudo smbpasswd -a kevin
```
```
sudo vim /etc/samba/smb.conf

文件末尾写入下列配置

[kevin]
    path = /home/kevin
    browseable = yes
    writeable = yes
    available = yes
    create mask = 0644
    public = no
    valid users = kevin

[global]
smb ports = 1314 1315
```

```
重启samba服务，使配置生效
systemctl restart smbd
```

# samba 答疑
sudo adduser 添加的是服务器用户，与samba无关，即linux用户，按照引导输入密码即可

sudo smbpasswd -a kevin 是将kevin用户加入到samba用户中，按照引导输入密码即可，
这里需要注意的是，这个密码和上面的密码可以一致也可以不一致，虽然用户都叫kevin，
但是一个是操作系统的用户，一个是app的用户，他们之间是独立的，只是同名而已

sudo 是sudo用户组成员临时行使root权力，这与linux严格的用户权限管理相关

这里也需要注意，如果path是别的路径，请确保smb用户对该路径有所有权，新手就不要乱搞了

# smb.conf 配置解析

path 指的是路径，不一定要开放当前用户的，也可以是其他路径，但通常习惯为用户目录

valid users 当public=no时候，就应该有valid users，表示只允许某个用户登录

only guest = yes 则表示仅以匿名用户登录

# 附录
删除用户命令:`sudo userdel -r kevin`

# small talk

github 强制启用 2FA ,真让人头大，国内的手机号没法作为验证方式，只能使用 2FA 应用来验证身份。

不支持国内手机，强烈差评，实在是不理解，对于这么多国内用户视而不见，被微软收购之后果然还是变了。

本来想用谷歌2FA验证的，但是转念一想，万一梯子不稳，又得折腾一阵子，想想还是算了。
