---
title: "tqdm_note"
date: 2022-09-19T16:08:33+08:00
draft: false
---
# tqdm
在看别人写的代码的时候发现的tqdm模块，当时还很好奇，这命名不像是标准库函数，于是乎去搜索了一下，是一个显示进度条的库

# 演示
试看如下代码：
```python3
from tqdm import tqdm
from time import sleep
for i in tqdm(range(0, 100), desc="加载中", colour="green"):
    sleep(1)
```
```angular2html
加载中:  70%|███████   | 70/100 [01:10<00:30,  1.01s/it]
```

当时第一次看得时候不太理解 01:10<00:30 这种显示方式，对此感到非常的不舒服，想要调整一下格式，去网上搜了搜tqdm的教程，发现清一色都是tqdm(range()),事实上和官方提供的大同小异，官方文档提供的例子更为丰富一些。

多次查找无果后，深感自己阅读文档的水平不足。

# 提高
为了解决 01:10<00:30 这个问题，忽而记起网上对tqdm库的描述，这是个纯python实现的库。点进去看源码，文件名std.py。

```python3
    def __init__(self, iterable=None, desc=None, total=None, leave=True, file=None,
                 ncols=None, mininterval=0.1, maxinterval=10.0, miniters=None,
                 ascii=None, disable=False, unit='it', unit_scale=False,
                 dynamic_ncols=False, smoothing=0.3, bar_format=None, initial=0,
                 position=None, postfix=None, unit_divisor=1000, write_bytes=None,
                 lock_args=None, nrows=None, colour=None, delay=0, gui=False,
                 **kwargs):
        """
        Parameters
        ----------
        iterable  : iterable, optional
            Iterable to decorate with a progressbar.
            Leave blank to manually manage the updates.
        desc  : str, optional
            Prefix for the progressbar.
        total  : int or float, optional
            The number of expected iterations. If unspecified,
            len(iterable) is used if possible. If float("inf") or as a last
            resort, only basic progress statistics are displayed
            (no ETA, no progressbar).
            If `gui` is True and this parameter needs subsequent updating,
            specify an initial arbitrary large positive number,
            e.g. 9e9.
        leave  : bool, optional
            If [default: True], keeps all traces of the progressbar
            upon termination of iteration.
            If `None`, will leave only if `position` is `0`.
        file  : `io.TextIOWrapper` or `io.StringIO`, optional
            Specifies where to output the progress messages
            (default: sys.stderr). Uses `file.write(str)` and `file.flush()`
            methods.  For encoding, see `write_bytes`.
        ncols  : int, optional
            The width of the entire output message. If specified,
            dynamically resizes the progressbar to stay within this bound.
            If unspecified, attempts to use environment width. The
            fallback is a meter width of 10 and no limit for the counter and
            statistics. If 0, will not print any meter (only stats).
        mininterval  : float, optional
            Minimum progress display update interval [default: 0.1] seconds.
        maxinterval  : float, optional
            Maximum progress display update interval [default: 10] seconds.
            Automatically adjusts `miniters` to correspond to `mininterval`
            after long display update lag. Only works if `dynamic_miniters`
            or monitor thread is enabled.
        miniters  : int or float, optional
            Minimum progress display update interval, in iterations.
            If 0 and `dynamic_miniters`, will automatically adjust to equal
            `mininterval` (more CPU efficient, good for tight loops).
            If > 0, will skip display of specified number of iterations.
            Tweak this and `mininterval` to get very efficient loops.
            If your progress is erratic with both fast and slow iterations
            (network, skipping items, etc) you should set miniters=1.
        ascii  : bool or str, optional
            If unspecified or False, use unicode (smooth blocks) to fill
            the meter. The fallback is to use ASCII characters " 123456789#".
        disable  : bool, optional
            Whether to disable the entire progressbar wrapper
            [default: False]. If set to None, disable on non-TTY.
        unit  : str, optional
            String that will be used to define the unit of each iteration
            [default: it].
        unit_scale  : bool or int or float, optional
            If 1 or True, the number of iterations will be reduced/scaled
            automatically and a metric prefix following the
            International System of Units standard will be added
            (kilo, mega, etc.) [default: False]. If any other non-zero
            number, will scale `total` and `n`.
        dynamic_ncols  : bool, optional
            If set, constantly alters `ncols` and `nrows` to the
            environment (allowing for window resizes) [default: False].
        smoothing  : float, optional
            Exponential moving average smoothing factor for speed estimates
            (ignored in GUI mode). Ranges from 0 (average speed) to 1
            (current/instantaneous speed) [default: 0.3].
        bar_format  : str, optional
            Specify a custom bar string formatting. May impact performance.
            [default: '{l_bar}{bar}{r_bar}'], where
            l_bar='{desc}: {percentage:3.0f}%|' and
            r_bar='| {n_fmt}/{total_fmt} [{elapsed}<{remaining}, '
              '{rate_fmt}{postfix}]'
            Possible vars: l_bar, bar, r_bar, n, n_fmt, total, total_fmt,
              percentage, elapsed, elapsed_s, ncols, nrows, desc, unit,
              rate, rate_fmt, rate_noinv, rate_noinv_fmt,
              rate_inv, rate_inv_fmt, postfix, unit_divisor,
              remaining, remaining_s, eta.
            Note that a trailing ": " is automatically removed after {desc}
            if the latter is empty.
        initial  : int or float, optional
            The initial counter value. Useful when restarting a progress
            bar [default: 0]. If using float, consider specifying `{n:.3f}`
            or similar in `bar_format`, or specifying `unit_scale`.
        position  : int, optional
            Specify the line offset to print this bar (starting from 0)
            Automatic if unspecified.
            Useful to manage multiple bars at once (eg, from threads).
        postfix  : dict or *, optional
            Specify additional stats to display at the end of the bar.
            Calls `set_postfix(**postfix)` if possible (dict).
        unit_divisor  : float, optional
            [default: 1000], ignored unless `unit_scale` is True.
        write_bytes  : bool, optional
            If (default: None) and `file` is unspecified,
            bytes will be written in Python 2. If `True` will also write
            bytes. In all other cases will default to unicode.
        lock_args  : tuple, optional
            Passed to `refresh` for intermediate output
            (initialisation, iterating, and updating).
        nrows  : int, optional
            The screen height. If specified, hides nested bars outside this
            bound. If unspecified, attempts to use environment height.
            The fallback is 20.
        colour  : str, optional
            Bar colour (e.g. 'green', '#00ff00').
        delay  : float, optional
            Don't display until [default: 0] seconds have elapsed.
        gui  : bool, optional
            WARNING: internal parameter - do not use.
            Use tqdm.gui.tqdm(...) instead. If set, will attempt to use
            matplotlib animations for a graphical output [default: False].
```

以往看一些源码都是一堆说明然后写个pass，这种实现方式一般都是使用c语言实现的，源码看起来会比较麻烦。而纯python实现的那可太好了。

bar_format 这个参数，想来就是我想要的了，看一下注释里bar_format的描述 default: '{l_bar}{bar}{r_bar}',试了试就理解了这三个参数的意义，很可惜的是依然不能解决我的问题。

再深入往里看，r_bar这个参数引起了我的注意，这应该就是我关注的部分了。随后找到format_meter函数，找到如下代码：
```python
r_bar = '| {0}/{1} [{2}<{3}, {4}{5}]'.format(n_fmt, total_fmt, elapsed_str, remaining_str, rate_fmt, postfix)
```
至此算是完了，但又没完。我翻遍整个std.py文件，没找到单独设置r_bar的地方，有的只是bar_format，换句话说就是原作者并没有对这个进行支持，所以无可奈何。除了直接修改tqdm源码，暂时没有想到更简单的办法，有些遗憾。

# 结语
对于纯python的第三方库，感到极其亲切，不像是底层c语言实现的一些标准库，看到一个空函数，一堆文字描述加上pass，实在是感到沮丧。直接阅读代码比阅读文档的方式可能来得更直接易于理解，仅仅是对于我而已，仅仅限制在对于tqdm库而言。

通常都是直接找官方文档，阅读源码的方式也不失为一种很好的办法，这种交流更为直接，明晰。
