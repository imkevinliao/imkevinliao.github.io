#!/usr/bin/bash
echo "please input article title："
read aritcal
hugo new posts/${aritcal}.md
