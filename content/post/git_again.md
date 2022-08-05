---
title: "git_again"
date: 2022-08-05T17:17:02+08:00
draft: false
---
# git clean
git clean 是一个高频率使用的命令，通常搭配reset使用
## git reset 
git reset --hard HEAD^ (回退到上个commit，删除两次commit中的修改）

git reset --soft HEAD^ (回退到上个commit，保留两次commit间的修改。也就是仅将指针指向上一个commit，保留自己的修改）

git reset (删除git commit提交的文件)
## git clean
git clean -n (git clean的演习，不进行任何删除操作，只是告诉你会删除什么文件，例如：git clean -ndf)

git clean -f (删除当前目录下所有没有track过的文件，后面可以带<path>表示指定路径下)
  
git clean -df (删除当前目录下所有没有被track过的文件以及文件夹)
  
git clean -xf (删除当前目录下所有没有track过的文件，不管是否.gitignore文件里指定的文件和文件夹)
  
git clean (轻易删除编译候产生的.o .exe等文件)
  
关于git clean使用，如果不太熟悉就是用 -n 参数进行一次演习更稳妥
  
# git push

git push origin HEAD:refs/for/<branchName>

# git checkout
git checkout -b <local_name> 
  
git branch --set-upstream-to=origin/<branchName>
  
git checkout -b 后面跟的是本地分支名字，可以自己命名，后面还可以继续跟分支表示依据哪个分支检出。    
（举例：git checkout -b local_dev master, git checkout -b local_dev origin/master)
