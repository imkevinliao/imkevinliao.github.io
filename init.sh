#!/bin/bash
cd public/ && git init && git remote add origin git@github.com:imkevinliao/imkevinliao.github.io.git && git pull origin master:public

chmod +x init.sh write.sh deploy.sh
