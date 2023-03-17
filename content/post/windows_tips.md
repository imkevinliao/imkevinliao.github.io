---
title: "windows_tips"
date: 2023-03-17T14:43:33+08:00
draft: false
---
# windows 泛用

windows下已经安装了git，如果git位置不对需要手动修改   
> start "Open Git Bash" "%SYSTEMDRIVE%\Program Files\Git\git-bash.exe" -c "ssh root@your_ip_address"

windows关机命令
> 关机命令(1h=3600，2h=7200，3h=10800)：shutdown -s -t 7200   
> 取消关机命令：shutdown -a

windows使某个应用开机启动
1. 调出运行框：windows + r 
2. 敲入并回车：shell:startup 
3. 在弹出的文件夹中将需要开机启动的应用快捷键放到这里即可

windows打开回收站
1. 调出运行框：windows + r 
2. 敲入并回车：shell:RecycleBinFolder

windows打开计算器（常用）
> 无论是在cmd 还是 powershell 亦或是 windows + r. 敲入并回车即可: calc   

查看硬盘类型
>命令:Get-PhysicalDisk,查看电脑硬盘属性ssd(固态)还是hdd(机械)

一些很有用的Bat命令：
```
Robocopy /MIR h:\MyBook\temp h:\MyBook\delete  ;文件路径太深无法删除，前一个为空文件夹，后一个为待删除的文件夹 
rd/s/q D:\app ;强制删除文件夹及子目录
ren *.flv *.mp4 ;批量改后缀(前面为原后缀，后面为修改后缀，文件同一目录下） 
FOR /F %%I IN ('DIR /B /S "D:\temp\*.*"') DO (MOVE %%I  "D:\Test") ;Pause ; 批量移动temp目录下所有文件到Test.   

文件路径找不到无法删除.拖拽进来即可:
DEL /F /A /Q \\?\%1
RD /S /Q \\?\%1

批量删除文件名中特定字符串:放在需要的目录下双击即可:
@echo off
Setlocal Enabledelayedexpansion
set "str=想要去掉的字符串"
for /f "delims=" %%i in ('dir /b *.*') do (
set "var=%%i" & ren "%%i" "!var:%str%=!")

查看电脑连接过的wifi密码:
for /f "skip=9 tokens=1,2 delims=:" %i in ('netsh wlan show profiles') do @echo %j | findstr -i -v echo | netsh wlan show profiles %j key=clear
```
