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
# git push -u origin master:public -f
