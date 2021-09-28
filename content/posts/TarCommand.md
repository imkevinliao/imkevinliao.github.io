---
title: "TarCommand"
date: 2021-09-29T00:19:04+08:00
draft: false
---

Tar Commond：

1.只打包不压缩，打包abc.txt文件到/home/abc.tar ：`tar -cvf /home/abc.tar /home/abc.txt` 

2.gzip压缩，将/home/*目录下所有文件打包并压缩到/home/abc.tar.gz: `tar -zcvf /home/abc.tar.gz /home/*`

3.bzip2压缩，将abc文件打包并压缩到/home/abc.tar.bz2: `tar -jcvf /home/abc.tar.bz2 /home/abc` 打包，并用bzip2压缩

如果是解压，将命令中的c替换为x即可，例如：`tar -zxvf /home/abc.tar.gz`


其他举例：

a.解压到指定目录，将文件解压到/zzz/bbs目录，该目录必须存在，否则报错 `tar -zxvf /bbs.tar.zip -C /zzz/bbs` 

b.将当前目录下的zzz文件打包到根目录下并命名为zzz.tar.gz `tar zcvf /zzz.tar.gz ./zzz`