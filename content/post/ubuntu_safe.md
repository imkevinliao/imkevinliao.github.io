---
title: "ubuntu_safe"
date: 2023-07-23T21:43:24+08:00
draft: false
---
# Ubuntu（Linux|UNIX）安全

这里特别指出是Ubuntu，市面上很多关于Linux的都是CentOS的，两者在大体上基本一致，但是由于作者本人知识面有限，在本人了解的范围内，这两个操作系统在很多地方还是有细微的差别，正因为他们之间存在一些小小的差异，所以我必须要指出这是一篇关于Ubuntu的安全文档(尽管他们差异很小)。

拓展：Ubuntu是基于Debian发展而来，所以Debian与Ubuntu差异极小；CentOS是Redhat的免费版。如果对Linux有了解的人应该知道，Linux的发行版基本分为两大派系，Debian和Redhat，很多其他名字的Linux发行版本基本都是基于这两大派系演变而来。

UNIX操作系统两大变种：Linux和MacOS，Debian属于Linux发行版，Ubuntu是基于Debian的发行版。所以MacOS与Ubuntu差异，应该可以看得出来。

之所以开篇指出CentOS和Ubuntu，是因为下面说的一些东西在两者上确实有一些区别，但我不想额外指出，所以本文限定在Ubuntu操作系统

# 超级用户
root作为超级用户，拥有最高的权限，可以执行删除整个操作系统的命令：`rm -rf /*`

一般用户通常是通过sudo来提权执行root操作，事实上如果拥有sudo权限，本质上和root没有任何区别。毕竟，你可以直接修改root用户密码，然后切换到root用户。

通常情况如果我们临时拥有sudo权限，如何偷偷给自己留个后门呢？直接修改root密码，这恐怕是最愚蠢的行为了。

## 方案一
原理（linux系统不是根据用户名来判断root用户，而是通过UID是否等于0来判断的）

基于该原理，我们创建一个用户，然后把UID设置未0那不就好了

创建用户并设置密码（注意这里是useradd，而不是adduser）
* `useradd kevin`
* `passwd kevin`
adduser会在创建用户的同时，在 /home/ 路径下创建对应的用户名文件夹，既然我们要偷偷的，那肯定是用useradd命令，因为它只会创建用户，不会做多余的事情。

编辑文件设置kevin uid=0，个人习惯vim编辑器，nano或其他文本编辑器都可
* `vim /etc/passwd`

找到创建的kevin用户：（实际因人而异，不一定是1001，也可能是其他的，一般Ubuntu操作系统第一个用户Ubuntu是1000，后面创建的依次递增）

kevin:x:1001:1001::/home/kevin:/bin/sh 改成 kevin:x:0:0::/home/kevin:/bin/sh

两个都改成0即可，这样kevin就是root用户了

该方案的问题显而易见，那就是一旦对方熟悉passwd这个文件，一眼便能看到这个奇怪的kevin用户。不过一般来说，以我个人的经验，很少有人能发现，因为大多数人根本不熟悉linux！！！且大家都忙着干活，哪有时间看这玩意。

## 方案二
原理（一般用户都是通过sudo来管理root权限的，既然如此，那我们自己偷偷整个sudo账户不就好了吗）

sudo 文件有/etc/sudoers这个文件，还有/etc/sudoers.d/ 目录下的所有文件

visudo 命令就可以直接打开/etc/sudoers这个文件，我们可以在文件最后一行看到这样一段注释：
`#includedir /etc/sudoers.d`

注意：这里虽然以#开头，表明是注释，但是实际上它是生效的，这应该只是一个提示。

我们既然要偷偷的，那么直接编辑sudoers这个文件就显得不那么明智，我们在/etc/sudoers.d/目录下创建一个文件，然后写入这么一行内容：

`kevin ALL=(ALL) NOPASSWD:ALL`

这里说明下NOPASSWD:ALL，这个可以让我们在使用sudo时候免去输入kevin账户密码的繁琐步骤，请确保使用sudo时候明确知道自己在干什么，不要做`sudo rm -rf /*`这样的事情

## 方案三
原理（使用系统默认组权限）这个理解起来比先前麻烦一些

我们使用id命令查看一下用户kevin `id kevin`，会得到下面的结果(因人而异)：uid=1001(kevin) gid=1001(kevin) groups=1001(kevin)

我们可以看到有一个 groups ，这个就是我们所谓的组。你可以理解为sudo是一个组，而所有属于sudo组的用户都拥有这个权限。解释不一定到位，自行理解。

`usermod -a -G sudo kevin`

将用户kevin追加到sudo用户组中，注意这里使用 -a 表示将kevin用户加入sudo用户组，一个用户可能在很多个用户组中，如果不使用 -a 命令，则会使得该用户只属于sudo用户组，一般我们追加即可。

这种方式较为隐秘，因为直接查看 /etc/sudoers.d 或者 /etc/sudoers 看不到kevin用户，并且在 /etc/passwd 中也是正常用户，没有什么异常，但是kevin已经拥有了sudo权限

ubuntu中sudo对应的是27

我们可以查看下group文件：`cat /etc/group`，可以看到 kevin 在 sudo 那一行里面。也可以通过命令 `getent group sudo` 查看。

## 总结
作为root管理员需要检查这些文件：（观察是否存在可疑用户）

/etc/passwd

/etc/sudoers

/etc/group

一般可以通过创建用户，然后设置UID为0-499中某一个合适的值，最好用户名也伪装成类似系统用户，这样可以迷惑大部分非专业人员，通常一般人不会去动系统核心的东西。然后再配合其他手段获取sudo权限。

一般而言使用方案三比较难被发现


# SSH连接安全
/etc/ssh/sshd_config

编辑该文件，这一部分需要详细了解可以去查看其他相关资料，这里只提关键的部分，以及注意修改配置文件后需要重启sshd服务 `sudo systemctl restart sshd`

```
PermitRootLogin yes
PermitRootLogin no
PermitRootLogin prohibit-password
对于 PermitRootLogin 参数的设置 yes和no 意义都很明确，允许和不允许root用户登录
这里我主要想解释下prohibit-password，这个代表不允许root用户密码登录，但是可以使用密钥登录

Port 22
通常22默认是ssh端口，有些时候我们会发现服务器经常被人尝试登录22端口，我们可以考虑换其他端口，虽然意义不大，但是当黑客发现你ssh端口非正常的22端口时候，他心里一定会想，事情开始变得有趣起来了。
linux新手就不要修改这个了

PasswordAuthentication yes
是否使用密码认证，设置为no不使用密码认证，转而使用密钥登录更安全
这里必须指出，请先验证密钥登录正常再修改这个，否则万一密钥无法登录，然后又不允许密码登录，那就难搞

PermitEmptyPasswords no
是否允许空密码用户登录，建议不允许
```

通常，我们会禁止root权限用户直接登录，只使用普通用户登录。设想这样一个场景，我们购买的服务器开启了ssh端口，黑客会通过暴力或其他方式远程登录到我们的服务器，如果我们只允许普通用户登录，那么即使黑客登陆到了服务器，他能做的事情也非常有限，他必须再想办法做一次提权操作，才能获得服务器完整权限。如果一开始就可以以root身份登录，那么将直接获取服务器所有权限，这显然更危险。

所以禁止root用户登录，然后使用ssh密钥登录，最后关闭允许密码认证，确保服务器安全。

最后再次强调，修改配置文件后一定要重启sshd服务器，不然等于没改。


# 附录

查看是否拥有sudo权限，看输出提示 `sudo -v`

直接编辑sudo文件 `visudo`
