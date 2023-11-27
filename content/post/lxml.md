---
title: "lxml"
date: 2023-11-26T23:35:21+08:00
draft: false
---
# 序言
lxml 的官方文档我是一直想吐槽的，界面太 low，没有搜索功能，搜索时候经常会跑到 xml 标准库，实在是令人头疼，
优点是 lxml 至今已经十余载了，可以说经历了时间的检验，已经足以证明它的可靠性。

本文总结的部分结论就是取自 lxml 官方文档 <https://lxml.de/tutorial.html>
# lxml 快速上手
注意：html 和 xml 都是标签对，但是 xml 标签对必须闭合，而 html 中存在一些无需闭合的标签对。

读取 xml 文件：
```python
from lxml import etree
filepath = ""
tree = etree.parse(filepath)
root = tree.getroot()
print(root.tag)
```
---
这里需要重点强调几个地方：
1. etree.dump(*arg) 会直接在终端打印出来
2. etree.SubElement 如果只是单纯的添加一个标签，但是标签内没有内容，那么将会是一个未闭合的标签对！！！可以自行查看打印效果
```python
from lxml import etree

root = etree.Element("html")
head = etree.SubElement(root, "head")
title = etree.SubElement(head, "title")
etree.dump(root)
print("*"*10)
title.text = "This is Page Title"
body = etree.SubElement(root, "body")
heading = etree.SubElement(body, "h1", style="font-size:20pt", id="head")
heading.text = "Hello World!"
para = etree.SubElement(body, "p", id="firstPara")
para.text = "This HTML is XML Compliant!"
para = etree.SubElement(body, "p", id="secondPara")
para.text = "This is the second paragraph."
etree.dump(root)
# with open("demo.html" ,'wb') as f:
#     f.write(etree.tostring(root,pretty_print=True))
# tree.write("demo.xml",encoding='utf8')

""" result:
<html>
  <head>
    <title/>
  </head>
</html>
**********
<html>
  <head>
    <title>This is Page Title</title>
  </head>
  <body>
    <h1 style="font-size:20pt" id="head">Hello World!</h1>
    <p id="firstPara">This HTML is XML Compliant!</p>
    <p id="secondPara">This is the second paragraph.</p>
  </body>
</html>
"""
```
xpath 语法：<https://docs.python.org/zh-cn/3/library/xml.etree.elementtree.html#module-xml.etree.ElementTree>
```python
from lxml import etree
tree = etree.parse('demo.html')
root = tree.getroot()
print(root.find('.//head/title').text)
print(root.find(".//*[@id='head']").text)
print(root.find(".//body/h1[@style]").text)
print(root.find(".//body/h1").text)
print(root.find(".//body/h1").attrib['style'])
```
# 进阶
通过 xpath 定位元素，然后进行操作，注意未查找到元素判空的情况 if element is not None。

这里需要说明，for i in iter 这种形式只能查找该标签下的子元素，不能迭代孙元素。

如果需要获取某个 node 下的所有子节点，应该使用 elements.iter() 作为迭代对象
```
elements = root.find(xpath)
if elements is not None:
    for ele in elements:
        print(ele.tag)
```

拷贝元素，当根据 xpath 定位到元素节点后，在拷贝时候和列表相同，使用 = 是浅拷贝。

想要拷贝节点信息，请使用 copy.deepcopy `new_elements = copy.deepcopy(elements)`

关于删除节点：
```
elements.clear()
-------------------------------------------
for element in elements:
    element.getparent().remove(element)
```

增加节点
```
# 追加节点
elements.append(user_element)

# 指定位置插入节点
html_element = lxml.html.fromstring("<hello>world</hello>\n")
elements.insert(0,html_element)

这里有一个坑：
html_element = lxml.html.fromstring("<hello>world</hello>\n")
elements.append(html_element)
elements.insert(0,html_element)
如果按上面操作，我们本来想要在 elements 的开头和结束都增加这个元素，
但是实际上后面的会覆盖前面的操作！！！
```

获取节点元素行号：
```
print(element.sourceline)

这里存在两个坑，
1. 行号是怎么计算的？行号是针对 root 而言的，是针对 root 而非是文档本身
我们举例一个 xml 文档，通常在文档开头有一行声明 <?xml version="1.0" encoding="utf-8"?>
那么当我们使用 etree.parse 读取文档时候，这行声明不包括在 root 中。
又例如，我们在 xml 文档前面留十行空白行，那么这十行也不会被 etree.parse 计入。

2. 行号是怎么计算的？行号不是按照程序员理解的那样，sourceline 的行号是从 1 开始的！
我们通常程序中开始迭代元素的时候，都是以 0 作为起始下标，所以写代码时候需要头脑清醒别搞混了
```

打印 etree 解析的节点内容
```
print(etree.tostring(element))

# 解决中文乱码问题，核心就是先编码后解码
print(etree.tostring(element, encoding="utf-8", pretty_print=True, method="html").decode("utf-8"))

# xml_declaration print 包括 xml 文档声明
print(etree.tostring(root, encoding="utf-8",xml_declaration=True, pretty_print=True).decode("utf-8"))
```

保存 xml 文件：
```
# 如果不需要 xml 声明，不填即可 （这里顺便提一下，这里写入的 xml 声明是内部创建的，并非原来文档的 xml 声明
# 例如原文档是双引号，这里是单引号

with open(filepath, 'w', encoding='utf8') as f:
    f.write(etree.tostring(root, encoding='utf8', pretty_print=True, xml_declaration=True).decode('utf-8'))
# method='xml', xml_declaration=True 如果method=html则不生效
tree.write(filepath, encoding='utf8', pretty_print=True, method ='xml', xml_declaration=True)
```

xml 格式化
```
自行设定缩进:通常是四个空格
这里需要注意：当我们第一次操作 xml，进行了插入节点等操作影响了相邻节点的缩进，持久化输出为 xml 后，文档显示极度不美观。
这个时候我们只需要重新读取输出后的 xml 再设置缩进，然后再次保存即可解决。
这个问题当时困扰了很久，才解决

etree.indent(root,"    ")
etree.indent(root,"\t")
```
