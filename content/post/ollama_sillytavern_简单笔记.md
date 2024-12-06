---
title: "ollama_sillytavern_简单笔记"
date: 2024-12-06T10:57:02+08:00
draft: false
---


# ollama 部署速览
1. ollama docker： docker pull ollama/ollama:latest

2. docker run -d --name ollama -v ollama_data:/ollama/data ollama/ollama:latest

3. ollama run wangshenzhi/llama3-8b-chinese-chat-ollama-q8 (中文大模型，也可以自行挑选模型)

## 本地部署：
1. Mac 官方脚本安装（默认下是本地11434端口）：curl -fsSL https://ollama.com/install.sh | sh  (安装完成后后迅速拉取大模型 ollama run llama3.1 因为这个很耗时)
2. 安装 ollama 官方 webui 界面： docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
3. 安装所需要的大模型：可以在终端下安装：ollama run llama3.1  也可以在 ui 界面下去操作
4. 本地 http://localhost:3000 or http://127.0.0.1:3000 访问 webui 并注册（这是离线作为管理员账号），然后就可以使用了

## 服务器部署
参考： https://www.cnblogs.com/qumogu/p/18235298
- curl -fsSL https://ollama.com/install.sh | sh  (安装完成后后迅速拉取大模型 ollama run llama3.1 因为这个很耗时)
- docker run -d --network=host -v open-webui:/app/backend/data -e OLLAMA_BASE_URL=http://127.0.0.1:11434 --name open-webui --restart always ghcr.io/open-webui/open-webui:main
- vim /etc/systemd/system/ollama.service
```
默认ollama绑定在127.0.0.1的11434端口，修改/etc/systemd/system/ollama.service，在[Service]下添加如下内容，使ollama绑定到0.0.0.0的11434端口
Environment="OLLAMA_HOST=0.0.0.0"
```
- 重启 ollama 服务：sudo systemctl daemon-reload && sudo systemctl restart ollama
- 访问你服务器公网ip， http://your_ip:8080

主要原因是 ollama 只允许本地访问，而 ollama-webui 是在 docker 内部，让 ollama-webui 使用主机网络，而端口也自然是主机的 8080 端口访问 webui。

## 进阶
模型部分：https://liaoxuefeng.com/blogs/all/2024-05-06-llama3/


# sillytavern 
## 一键部署

```docker run -d --name sillytavern -e TZ="[TimeZone]" -p 8000:8000 -v sillytavern-plugins:/home/node/app/plugins:rw -v sillytavern-config:/home/node/app/config:rw -v sillytavern-data:/home/node/app/data:rw --restart always ghcr.io/sillytavern/sillytavern:latest ```

如果是本地使用上面已经完成了，可以直接本地+端口8080直接访问

## 公网访问

下面是为了能在公网访问，例如“酒馆”部署在服务器的场景：

进入容器 “酒馆” 内部：```docker exec -it sillytavern sh```

vi config.yaml  -> 白名单访问  （这里是修改配置文件开放外部访问，需查看酒馆文档操作，不详细指出）

重启酒馆 ```docker restart sillytavern```

公网访问：your_ip:8000

