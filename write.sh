#!/bin/bash
echo "please input article title: "
read aritcal
hugo new post/${aritcal}.md
git status
