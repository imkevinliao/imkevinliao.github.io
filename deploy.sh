#!/bin/bash
git status

read -p "your commit message:" msg
if [ ! -n "$msg" ]; then
    msg="."
fi

echo "===master==="
hugo  && git add .  && git commit -m "$msg"  && git push
echo "===master==="

echo "===public==="
cd public/ git add . && git commit -m "."
git push origin master:public --force
echo "===public==="

# 项目分支：git push -u origin master:master -f
# 网站分支：cd public/ && git push -u origin master:public -f

# The file will have its original line endings in your working directory
# git config --global core.safecrlf true

# fatal: LF would be replaced by CRLF
# git config --global core.autocrlf false
