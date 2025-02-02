#!/bin/bash
git status

read -p "your commit message:" msg
if [ ! -n "$msg" ]; then
    msg="."
fi

dir=public
if [ -d "$dir" ]; then
    rm -rf $dir
fi

hugo  && git add .  && git commit -m "$msg"  && git push
echo "************************************************** master branch push okay **************************************************"

git config --global init.defaultBranch master
cd public/ && git init && git remote add origin git@github.com:imkevinliao/imkevinliao.github.io.git
git add . && git commit -m "." && git push origin master:public --force
echo "************************************************** public branch push okay **************************************************"
