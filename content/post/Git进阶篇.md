---
title: "Git进阶篇"
date: 2022-10-20T22:12:08+08:00
draft: false
---

# Git Day Day Up
在工作中使用了一段时间Git后，对Git也有了新的领悟

- 查看当前commit id（当然你也可以使用git log）：git rev-parse --short HEAD
- Git检出远程分支：git checkout -t origin/xxx

对于检出远程分支这里我觉得有必要重点提一下：  
检出远程分支时候，如果采用git checkout origin/xxx，则会导致HEAD detached from *** , 产生原因将本地git的头指针指向origin库的分支，而origin不是你本地的，只能指向它的id，并不能切过去。

- 关于分支的一些操作：git branch -a;git branch -d xxx;git branch -vv;

- Git回退：git reset --hard  5a20bd9;git reset --soft  5a20bd9

# Git解析：
- git push origin HEAD:refs/for/xxx   
origin是远程库的名字，HEAD是一个特别的指针，可以把他当作本地分支的别名，这样git就知道你工作在哪个分支   
refs/for:指的是提交代码到服务器后需要code review之后才能进行merge操作    
refs/heads:不需要code review      

git rebase origin/xxx   
变基，以当前分支为准，将远程xxx最新代码合入当前分支，作用：更新代码。解释：
```
git checkout master
git pull origin master
git checkout branchA
git rebase master
将本地master最新代码合入branchA分支
```
# Git Stash and Pop
为什么要单独把它拎出来呢，因为实际使用后觉得太棒了，怎么说呢，应该是一个高频使用的命令。在建议的同时，更建议使用git stash save取代git stash，使用git stash apply取代git pop。   
用法举例：
```
git stash save "your comments such as test-cmd-stash"
git stash apply stash@{0}
git stash drop stash@{0}
------
git stash list
git stash clear
git stash show
```

# Git Log
这一篇文章足以 <https://www.cnblogs.com/bellkosmos/p/5923439.html>

# Git Error
git 提交出现无效committer，请检查email配置是否正确
# 关于Git每次进入都需要输入用户名和密码的问题解决    
git bash进入你的项目目录，输入：git config --global credential.helper store  
然后你会在你本地生成一个文本，上边记录你的账号和密码。当然这些你可以不用关心，你使用上述的命令配置好之后，再操作一次git pull，然后它会提示你输入账号密码，这一次之后就不需要再次输入密码了。
