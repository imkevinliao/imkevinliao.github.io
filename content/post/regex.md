---
title: "regex"
date: 2022-06-13T16:51:37+08:00
draft: false
---
# 正则
正则的概念是很早很早以前就接触过的，但是并没有实际使用。记忆中开始实际使用的时候，似乎是我开始写java的时候。至于为什么使用正则，真的是忘了，但是我清楚的记得当时有一个东西无法匹配，我折腾了很久也无可奈何，最后还是找大佬指点了一下，我才豁然开朗。至此，我记住了全部匹配的\s\S，也是从那个时候开始正式接触正则的概念：零宽断言。我当时兴致勃勃的要深入理解正则表达式，达到随意写的状态，但是大佬一句话，正则表达式用的时候网上搜一下就行，没必要记。毕竟，你要匹配的很多网上的表达式写的都很好了，自己写还烂。

如今回看当初，只觉得好笑。初见正则，很多东西都搞不清楚，如search，findall，断言，匹配开头，匹配结尾，贪婪模式，非贪婪模式，匹配次数。大概是没有老师指点吧，现在回看觉得简单的东西，当时却折腾了很久，以至于当时气馁的感觉至今仍然能有些许感受。

人生不也是如此吗？在人生的某个节点上，我们感到无比痛苦，我们感到无可奈何，我们对自己无能而产生愤怒，产生痛苦。在那个时刻，我们备受煎熬，可，一旦往事随风后，再回头看，似乎也没什么大不了，不就是......

# 反复温习
正则表达式一段时间不使用后，就容易被遗忘。所以谨以这短短的几行文字做记录，以便后续快速回忆。
## 参考链接：
<https://www.jb51.net/tools/regex.htm>  
<https://www.runoob.com/w3cnote/reg-lookahead-lookbehind.html>
## Python代码
```Python3
def regular_assertion():
    m_str = r'regex represents regular expression'
    print(f'match str：{m_str}')
    for index, value in enumerate(m_str):
        print(index, end='')
        print(value, end=' ')
    # 正向先行断言 负向先行断言 正向后行断言 负向后行断言
    reg = [r're(?=gular)', r're(?!g)', r'(?<=\w)re', r'(?<!\w)re']
    for i in range(4):
        print(f'\n匹配规则：{reg[i]}')
        m = re.finditer(reg[i], m_str)
        if m:
            print(f'匹配结果:')
            for _ in m:
                print(_, end=' ')
                print(_.group(), end='; '  
```
打印结果：
```
match str：regex represents regular expression
0r 1e 2g 3e 4x 5  6r 7e 8p 9r 10e 11s 12e 13n 14t 15s 16  17r 18e 19g 20u 21l 22a 23r 24  25e 26x 27p 28r 29e 30s 31s 32i 33o 34n 
匹配规则：re(?=gular)
匹配结果:
<re.Match object; span=(17, 19), match='re'> re; 
匹配规则：re(?!g)
匹配结果:
<re.Match object; span=(6, 8), match='re'> re; <re.Match object; span=(9, 11), match='re'> re; <re.Match object; span=(28, 30), match='re'> re; 
匹配规则：(?<=\w)re
匹配结果:
<re.Match object; span=(9, 11), match='re'> re; <re.Match object; span=(28, 30), match='re'> re; 
匹配规则：(?<!\w)re
匹配结果:
<re.Match object; span=(0, 2), match='re'> re; <re.Match object; span=(6, 8), match='re'> re; <re.Match object; span=(17, 19), match='re'> re; 
```
# 结语
子曰，温故而知新，诚不欺我
