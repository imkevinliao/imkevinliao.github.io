---
title: "markdown私人语法"
date: 2022-02-16T21:16:14+08:00
draft: false
---
# markdown语法
代码高亮可以指定编程语言，也可以不指定  
\```python  
#!/usr/bin/env python3  
print("Hello, World!");  
\```  
如果是markdown文档，显示效果如下：
```python
#!/usr/bin/env python3
print("Hello, World!");
```
\> 表示引用
如果是markdown文档，显示效果如下：
> 这是markdown的个引用，每行开头使用>即可

表格方式的写法
```
|用户|性别|id|
|---:|:---:|:---| 
|欧阳松田|男|732324345|
|周康|女|2423479|
|陆抗|男|345592|
```
如果是markdown文档，显示效果如下： 左对齐，右对齐，居中对齐可以很清楚看到
|用户|性别|id|
|---:|:---:|:---|
|欧阳松田|男|732324345|
|周康|女|2423479|
|陆抗|男|345592|

任务列表的写法，这里也可以看到无序列表，*(Green) -(Red) +(Blue)都是可以的
```
- [ ] a task list item
  - [x] completed
  - [ ] incomplete
- [ ] list syntax required
- [x] completed
```
如果是markdown文档，显示效果如下：
- [ ] a task list item
  - [x] completed
  - [ ] incomplete
- [ ] list syntax required
- [x] completed

脚注这一块留个印象就好了：
```
在这段文字后添加一个脚注[^footnote].
[^footnote]:这里是脚注的内容.
markdown代码如下：
使用 Markdown[^1]可以效率的书写文档, 直接转换成 HTML[^2], 你可以使用 Typora[^T] 编辑器进行书写。
[^1]:Markdown是一种纯文本标记语言
[^2]:HyperText Markup Language 超文本标记语言
[^T]:NEW WAY TO READ & WRITE MARKDOWN.
```
在新标签页打开链接:
```
[百度](https://www.baidu.com){:target="_blank"}  
<https://www.baidu.com>{:target="_blank"}
```
如果是markdown文档，显示效果如下：Github似乎不支持    
[百度](https://www.baidu.com){:target="_blank"}  
<https://www.baidu.com>{:target="_blank"}
