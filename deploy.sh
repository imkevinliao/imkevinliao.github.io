#!/bin/bash
git status

read -p "your commit message:" msg
if [ ! -n "$msg" ]; then
    msg="."
fi

# 如果存在public则删除该文件夹
dir=public
if [ -d "$dir" ]; then
    rm -rf $dir
fi

echo "===master==="
hugo  && git add .  && git commit -m "$msg"  && git push
echo "===master==="

echo "===public==="
cd public/ && git init && git remote add origin git@github.com:imkevinliao/imkevinliao.github.io.git
git commit -am "." && git push origin master:public --force
echo "===public==="


# The file will have its original line endings in your working directory
# git config --global core.safecrlf true

# fatal: LF would be replaced by CRLF
# git config --global core.autocrlf false
