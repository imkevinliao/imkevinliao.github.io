---
title: "代码设计-Python"
date: 2023-12-14T22:32:08+08:00
draft: false
---
# 代码设计
一直都很相谈谈代码设计，正好最近工作上写了些代码，颇有感悟。

# 为什么需要设计
通常一个小的项目，写代码的时候总是直接开干，尤其是Python，刷刷两下就搞完了，对于代码中的魔鬼数字毫不在意。哪怕是现在，对于这种模式，并不觉得有什么问题。

并不是所有的代码都需要经过深思熟虑才能下笔的，代码写的多了，其实直接干小项目问题不大。

所以设计是多余的吗？多余也不多余。

之所以需要设计，是因为代码需要维护，并不是像武侠小说中的那样，一招打遍天下无敌手，代码如果长期需要使用，就必须要进行维护。代码的差距，其实就体现在可维护性上。
对于需要维护的项目，最好也必定会需要设计，即便一开始不进行顶层设计，最后也必然会因为各种问题，选择重新设计。

# 如何设计
关于如何设计，很难给出确切的答案，因为本身就困在这个层次几年了，只能谈谈看法。

对于 Python 代码，尽可能对入参写上注释。有数据需要处理的，必须顶层设计好数据存储路径，这点非常重要。

代码设计必须考虑到中断的问题，例如程序处理到一半，突然出现个没有考虑到的异常，修复后可以接着跑，而无需从头再来。

关于文件夹的创建，一定时在文件数据已经准备好，进行写入的前一步进行创建。曾经在写代码时候考虑一次性将所有路径的文件夹都生成好，然后再把文件写进去。
这样子的问题就是在 debug 期间，如果创建了大量的空文件夹，到时候很不方便，而写的时候创建则容易定位出错。即，文件夹创建， 那么必定是写入那里的代码出现问题，
若文件夹没有创建，则表示还没有执行到这里。

尽量不要在局部变量中使用可能会在全局变量中用到的变量名，在 Python 中，只要避免这一种情况，可以大大提高程序的维护，因为全局变量一旦不再是全局变量，
那么可能会破坏大量函数。名称重复也会导致有些时候写的时候不注意，搞错了。

# 极致的设计
事实上，如果一味的追求设计，而完全不进行代码编写，想着设计好一切结构，代码编写就一帆风顺，那简直是异想天开。
就像是拷贝复制文件这种事情，也存在 Windows 下路径过长导致找不到文件的问题，再比如这个路径是别人共享给你的路径，又会有新的问题。
“绝知此事要躬行”，这就像是电脑的多线程工作，一边设计一边工作，而不是必须等待设计完美无缺再进行工作。

# 设计的意义
代码设计的意义是为了提高维护性，没有谁的代码一写下来就是无可挑剔的，不要指望一次设计，一次编写就可以解决所有问题。代码设计存在边界效应，
正是因为大部分人没有设计的概念，所以才需要代码设计，将边界的收益拉高。不要为了设计而设计，好的代码不是一蹴而就，需要不断打磨。设计亦是如此。
