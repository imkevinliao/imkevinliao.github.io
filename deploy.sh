#!/usr/bin/bash
git status

read -p "input commit for this push:" commit
if [ ! -n "$commit" ]; then
    commit="."
fi
echo "==============================="
hugo  && git add .  && git commit -m "$commit"  && git push
echo "==============================="

cd public/ && git add . && git commit -m "." 
git push origin master:public
# 第一次部署出错请使用下面的命令:
# 第一个项目仓库，第二个网站仓库
# git push -u origin master:master -f
# git push -u origin master:public -f
