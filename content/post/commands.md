---
title: "commands"
date: 2022-04-15T22:35:16+08:00
draft: false
---
# windows and linux command

## linux command
Q:How can I list all human users that I've created?    
A:Human users have UIDs starting at 1000, so you can use that fact to filter out the non-humans  
```
command1: cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1
command2: awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd
```
Q:How to show the commit id of HEAD?  
A:You can use the following three ways. 
```
$ cat .git/HEAD
ref: refs/heads/v3.3
$ cat .git/refs/heads/v3.3
6050732e725c68b83c35c873ff8808dff1c406e1

git rev-parse HEAD
git rev-parse --short HEAD 

git show-ref --head

PS:
git reset --soft HEAD^
git reset --hard  4dbee3639
```
Q:How to login linux by one command with password?     
A:maybe you should apt install sshpass,for example:sshpass -p mypasswd ssh root@192.168.1.12
```
sshpass -p [passwd] ssh -p [port] root@ip
```
## windows command
Q:How to install telnet on windows?   
A:using telnet like this(telnet ip port): telnet 1180.76.76.76 22
```
dism /Online /Enable-Feature /FeatureName:TelnetClient
```
Q:How to shutdown my windows cool?   
A:Create a file, write this `shutdown -s -t 0`,rename the file name extension to .sh, click double it!

## others
Q：about terminal proxy(V2ray)： 
```
windows command use this：
set http_proxy=http://127.0.0.1:10809 
set https_proxy=http://127.0.0.1:10809
linux command use this:
export http_proxy=http://127.0.0.1:10809
export https_proxy=http://127.0.0.1:10809
```
open gitbash and do your command: 
```
start "Open Git Bash" "%SYSTEMDRIVE%\Program Files\Git\git-bash.exe" -c "ssh root@43.128.26.119
```
