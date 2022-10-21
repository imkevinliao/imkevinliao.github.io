---
title: "记录vscode远程连接问题"
date: 2022-05-18T23:12:48+08:00
draft: false
---
# VSCode远程连接问题
问题描述："Bad Owner or Permissions on username\.ssh\config file"

当时没有把问题记录下来，但是记得网上有个和我差不多，几乎可以认定是相似的报错。
"https://github.com/microsoft/vscode-remote-release/issues/6714"

我看了这个Issue，回复是，因为是非英文所以不予回答，当时看到的时候，人都傻了。用中文大白话搜了下结果基本上给出的回答都是删除C:\Users\user\.ssh\known_hosts，大概是记录和实际不匹配。但是我试了并无任何效果。

一度被这个问题搞到放弃vscode，可惜没有找到好的替代品，也是因为用习惯了，看到了jetbrain的fleet，不过还没有正式发布，哎，发布了没准我就丢了vscode了。既然找不到替代品，那就只好试着去解决了。vscode反复装了很多遍，文件清了很多次，依旧无疾而终。

后来我试着用英文搜索，也就是开头问题描述的那一段，果然找到了。"https://github.com/microsoft/vscode-docs/issues/3210"并且在这里面找到了解决方案。值得一提的是这里面也有很多人是通过删除hosts解决的。我也试了这里面提到的双斜杠，也怀疑是windows的老问题了，试了试`C:\\User\\Alexander.ssh\\config`，无效。

随后又试了IdentityFile C:/Users/johndoe/.ssh/id_rsa，说实话，这种方式我一度觉得应该可以，可是希望再一次落空。

我扫了扫，看见一个人说修改settings.json文件来实现，我觉得可行，但是前面的多次失望让我觉得不太可能，又因为我很不喜欢修改配置文件，这个毕竟比较麻烦。我就试着把git的ssh写进配置。
"remote.SSH.path": "C:/Program Files/Git/usr/bin/ssh.exe"

神奇的解决了，怎么说呢，事实上，这可能不叫解决问题，因为问题还是存在，只不过我用git的ssh替代了，间接解决了这个问题。有些遗憾，大概就是那种如鲠在喉的感觉吧，总有些不舒服。

# 更新
这个问题会发生在更新vscode过程中，如果本地更新，服务器更新失败（手动登录服务器删除原来的vscode后重新连接）
