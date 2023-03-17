---
title: "python_algorithm"
date: 2023-03-17T14:39:19+08:00
draft: false
---
# Python 算法及数据结构
记不得过去的人，注定要重蹈覆辙

动态规划的本质就是用空间换时间，很多时候我们不在乎程序浪费了多少空间，因为现在的存储空间很廉价，但是我们很在乎时间，它非常昂贵。
# 斐波那契数列
```python
def fib(n):
    if n < 0:
        return 0
    if n == 1:
        return 1
    return fib(n - 1) + fib(n - 2)
   
def fib_dy(n):
    if n < 0:
        return 0
    dp = [-1] * (n + 1)
    print(dp)
    dp[1] = dp[2] = 1
    for i in range(3, n + 1):
        dp[i] = dp[i - 1] + dp[i - 2]
    print(dp)
    return dp[n]
    
start = time.time()
print(fib_dy(1000))
end = time.time()
print(end - start)
```
斐波那契数列理解起来非常简单，如果不是亲自实验，我从未想过简单的改变能对性能有巨大的提升。

fib 函数是根据定义写出来的，我们通常都是使用递归的方式去实现，当然代码不一定这么写，但是思想基本都是递归的思想。试着想一下，用递归思想，当我要计算 fib(1000) 的时候，我要先计算 999 和998，而计算 999 需要先计算998和997，那么仅仅这里就不难看到计算 1000 需要计算 998，计算 999 也需要计算 998，也就是计算了两次，依此类推，递归计算量是很大的。

fib_dy 函数是根据动态规划来计算的，先建立一个 n+1 的数组，每一次的数据都保存下来了，不需要重复的计算。

fib_dy(1000) 所花费的时间也不过 0.0059s

fib(1000) 则直接无法计算，递归的嵌套太深了，我们当然可以通过优化代码来使其生效，但是计算 fib(20) 所花费的时间就已经达到了 0.0029s，计算 fib(30) 达到了 0.337s

---------------------------
动态规划升级版本，从一维到二维

```
一个机器人位于 m 乘以 n 个网格左上角，机器人每次只能向下或者向右移动一步 到达右下角有几种路径？
m 为行数 n 为列数

解题思路：
由于机器人只能向右或者向下行动，不可以逆

状态定义：dp(i,j)表示从左上角走到（i,j)路径的数量，例如一个2*2的网格，从左上角到右下角只有两种可能，先右后下，先下后右。

状态转移方程：dp(i,j) = dp(i-1,j)+dp(i,j-1)
```
```python
m, n = 3, 7
dp = [[0] * n for _ in range(m)]
# 初始化dp数组
dp[0][0] = 1
for i in range(m):
    dp[i][0] = 1
for j in range(n):
    dp[0][j] = 1

for i in range(1, m):
    for j in range(1, n):
        dp[i][j] = dp[i - 1][j] + dp[i][j - 1]
# 数组下标是从 0 开始的，通过查表的方式得到结果
print(dp)
print(dp[m - 1][n - 1])
```
```python
m, n = 3, 7
dp = np.ones([m, n])
print(dp)
for i in range(1, m):
    for j in range(1, n):
        dp[i][j] = dp[i - 1][j] + dp[i][j - 1]

print(dp)
```
numpy 的方式看的更清楚一些, numpy 结果
```
[[ 1.  1.  1.  1.  1.  1.  1.]
 [ 1.  2.  3.  4.  5.  6.  7.]
 [ 1.  3.  6. 10. 15. 21. 28.]]
```
我们可以看到，从左上角到右下角有28种方式，28实际上是21+7的结果，因为要到达28这个点，根据题意，只能是从21或者是从7这个点到达。

让我们看看7*7的表格
```
[[  1.   1.   1.   1.   1.   1.   1.]
 [  1.   2.   3.   4.   5.   6.   7.]
 [  1.   3.   6.  10.  15.  21.  28.]
 [  1.   4.  10.  20.  35.  56.  84.]
 [  1.   5.  15.  35.  70. 126. 210.]
 [  1.   6.  21.  56. 126. 252. 462.]
 [  1.   7.  28.  84. 210. 462. 924.]]
```
我们通过这种方式，无论是想要查询哪一个都是非常轻而易举的行为 print(dp[m-1][n-1])