
---
title: "Git"
date: 2021-09-30T00:19:27+08:00
draft: false
---

看了很多人的Git教程，但是学习还是要多实践，多敲几次命令，才能真正掌握。<!--more-->git的命令繁多，取其中比较高频使用的记录下。  

1. git init 
2. ```git remote add origin git@github.com:KevinStarry/kevinstarry.github.io.git``` 添加远程仓库地址
3. ```git pull <remote> <branch>``` 拉取远程仓库某个分支到本地，如：git pull origin master。拉取远程仓库的master到本地。等同于fetch + merge 命令：git fetch origin branchName，git merge origin/branchName。
4. git pull origin master --allow-unrelated-histories。允许不相关的合并，手动解决冲突。
5. ```git push <远程主机名> <本地分支名>:<远程分支名>``` 推送到远程，如：git push origin master:master。推送本地master到远程master。如果省略远程分支名，表示本地分支名与远程分支同名。如果省略本地分支名如：git push origin :master，则表示删除远程分支master，因为这表示推送本地空分支给远程。  
6. git push -u origin master 建立当前分支和远程分支的追踪关系。关系建立后可以直接使用 git push 推送到远程。
7. git push -f origin 强制推送到远程，慎用，将本地文件直接推送到远程。
8. git branch -a 查看所有分支（包括远程分支）。
9. git branch -vv 查看本地分支关联对应的远程分支。
10. git branch -m branchname 修改当前分支的名字。
11. git diff origin/branchname..branchname 查看远程分支和本地分支的对比。
12. git diff origin/branchname..origin/branchname  查看远程分支和远程分支的对比。
13. git diff branchname..branchname 查看两个本地分支所有的对比
14. git checkout branchName 切换分支
15. git checkout . 恢复暂存区的所有文件到工作区。
16. git add . 或者 git add -A ，追踪所有文件提交到暂存区。
17. git commit -m "." 提交。
18. git tag -a v0.1 -m "version 0.1 released"  创建带有说明的标签，用 -a 指定标签名，-m 指定说明文字。
19. ```git push origin <tagname>``` 推送一个本地标签。
20. git reset 等价于 git reset HEAD （默认）将当前的分支重设(reset)到指定的\<commit> 或者 HEAD (默认，如果不显示指定 \<commit>，默认是 HEAD ，即最新的一次提交)。
21. git checkout -b aaa 创建一个 aaa 分支，并切换到该分支 （新建分支和切换分支的简写）。
22. git checkout -b aaa master  可以看做是基于 master 分支创建一个 aaa 分支，并切换到该分支。
23. git branch branchname 切换分支(切换分支时，本地工作区，仓库都会相应切换到对应分支的内容)。
24. git branch -D branchname 强制删除一个本地分支，即使包含未合并更改的分支。

git revert命令用来撤销某个已经提交的快照（和 reset 重置到某个指定版本不一样）。它是在提交记录最后面加上一个撤销了更改的新提交，而不是从项目历史中移除这个提交，这避免了 Git 丢失项目历史。  
撤销（revert）应该用在你想要在项目历史中移除某个提交的时候。比如说，你在追踪一个 bug，然后你发现它是由一个提交造成的，这时候撤销就很有用。  
撤销（revert）被设计为撤销公共提交的安全方式，重设（reset）被设计为重设本地更改。

# 常见问题
1. 拉取别人的远程分支合并后，git 会存取这个拉取的记录，如果你不小心删了别人的上传的文件，这时候想要再拉取别人的分支是没用的，会显示 already-up。这时候可以回滚代码，重新拉取。
2. fatal：refusing to merge unrelated histories 拒绝合并不相关的历史，在 git 2.9.2 之后，不可以合并没有相同结点的分支（分支之间自仓库建立后，从来没有过互相拉取合并）。如果需要合并两个不同结点的分支，如下：
git pull origin branchName --allow-unrelated-histories   
git merge branchName --allow-unrelated-histories  
3. 合并分支时出现问题，想要解除合并状态
> error: merge is not possible because you have unmerged files.  
> hint: Fix them up in the work tree, and then use 'git add/rm \<file>'  
> hint: as appropriate to mark resolution and make a commit.  
> fatal: Exiting because of an unresolved conflict.  
当远程分支和本地分支发生冲突后，git 保持合并状态，你如果没有去解决完所有的冲突，那么 git 会一直保持这个状态，你就无法再提交代码。只有先解除合并状态后，才能继续提交。执行命令前最好先备份一下，有可能本地做的修改会被远程分支覆盖掉。  
解除合并状态 git merge --abort 
4. git 不允许提交空文件夹,可以在当前目录下，添加一个 .gitkeep 文件。
# 参考
三年git使用心得：<https://www.cnblogs.com/chengxuyuanaa/p/13171651.html>
