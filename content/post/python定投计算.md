---
title: "定投计算"
date: 2021-11-08T21:34:47+08:00
draft: false
---

# 起因
看见身边的朋友都开始理财，所以也就关注了一下，也知道巴菲特提的定投是普通人最好的投资方式。定投被吹的太厉害，恰好看到一篇文章，写的是每月定投500和每月定投1000，十年后差别巨大。读这篇文章的时候还没有意识到什么，直到我看到评论区两个人的争吵，我忽然醒悟。

A轻蔑的说，定投500和定投1000，不就是定投两个500吗，还什么差别巨大。B一脸鄙视的说，懂不懂什么是复利？A只是留下一句好好学学数学，就没有后续了。

当时脑子也是短路了，一时间也没反应过来。现在想想，还是被魔化的定投给限制住了思考。

# 正文
一时兴起，想着用Python来写个方法实现这个定投的计算。还没开始写我就开始拘泥于形式，这也算是我的通病了，代码一个字没敲就想着要优雅，要好看。

直接贴代码了，感谢我的朋友们

```py
# 设初始投资为x0，第1次存入为x1，第2次存入为x2等等，期末资金为f，一计息周期的利率y，复利次数为n
# f = x0*(1+y)**n+x1*(1+y)**(n-1)+x2*(1+y)**(n-2)+...
# 补充说明，月利率=年利率/月数，按月定投


def invest_calculate() -> float:
    capital = float(input('投资的本金是（单位万元）：'))
    original_year_rate = input('预期年化率是：')
    if '%' in original_year_rate:
        original_year_rate = float(original_year_rate.strip('%'))/100
    year_rate = float(original_year_rate)
    invest_times = int(input('计划投资的年数：')) * 12
    invest_once = float(input('单次(每月）投资的金额是（单位万元）：'))
    # 本金部分的收益：
    income = capital * (1 + year_rate / 12) ** invest_times
    # 定投部分的累计收益：
    for i in range(1, invest_times + 1):
        income = income + invest_once * (1 + year_rate / 12) ** (invest_times - i)
    # 一共投入的资金：
    all_invest = capital + invest_once * invest_times
    print(f'投资的本金是：{capital}万元，年化率是：{original_year_rate}，计划投资{invest_times / 12}年，单次投资金额是：{invest_once}万元')
    print(f'一共投资金额为：{all_invest}万元,最后期望收益是：{income:.2f}万元，收益/投资={income / all_invest:0.2f}')
    return income


invest_calculate()
```
看一下结果吧：
```
投资的本金是（单位万元）：0
预期年化率是：0.12
计划投资的年数：10
单次(每月）投资的金额是（单位万元）：0.1
投资的本金是：0.0万元，年化率是：0.12，计划投资10.0年，单次投资金额是：0.1万元
一共投资金额为：12.0万元,最后期望收益是：23.00万元，收益/投资=1.92
```

# 结语：
定投的魅力是无穷的
