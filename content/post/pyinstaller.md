---
title: "pyinstaller"
date: 2023-07-20T22:23:40+08:00
draft: false
---

# Pyinstaller 介绍
PyInstaller是一个在Windows、GNU/Linux、macOS等平台下将Python程序冻结（打包）为独立可执行文件的工具, 用于在未安装Python的平台上执行Python编写的应用程序。

# 生成标准spec文件
Pyinstaller不支持交叉编译，但是可以在不同平台上进行打包。

先提示，在Mac上打包可能会存在一些问题（例如遇到图标格式不对，Windows和Mac使用的Icon格式不相同；再比如一些安全问题会导致Pyinstaller命令需要进行一定的配置才能使用）

Windows使用举例：

假定你编写了一个Python文件，名字叫：check.py，文件路径：D:\github\check.py

Pycharm中在该路径打开终端即可，通常我们会构建虚拟环境来创建Python项目以确保不会污染系统环境，终端显示（venv）代表启用了虚拟环境，确保虚拟环境已经安装pyinstaller，如果没有显示则代表终端使用的是系统环境，请确保系统环境中安装pyinstaller，这里不多赘述。

终端命令：`pyinstaller.exe .\check.py` 该命令会生成一个 check.spec 文件

spec文件内容如下：（生成的内容不一定完全相同，这里只是做一个展示，行号是我特意加上去的，方便解释）
```
0# -*- mode: python ; coding: utf-8 -*-

1

2

3block_cipher = None

4

5

6a = Analysis(

7    ['check.py'],

8    pathex=[],

9    binaries=[],

10    datas=[],

11    hiddenimports=[],

12    hookspath=[],

13    hooksconfig={},

14    runtime_hooks=[],

15    excludes=[],

16    win_no_prefer_redirects=False,

17    win_private_assemblies=False,

18    cipher=block_cipher,

19    noarchive=False,

20)

21pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

22

23exe = EXE(

24    pyz,

25    a.scripts,

26    [],

27    exclude_binaries=True,

28    name='check',

29    debug=False,

30    bootloader_ignore_signals=False,

31    strip=False,

32    upx=True,

33    console=True,

34    disable_windowed_traceback=False,

35    argv_emulation=False,

36    target_arch=None,

37    codesign_identity=None,

38    entitlements_file=None,

39)

40coll = COLLECT(

41    exe,

42    a.binaries,

43    a.zipfiles,

44    a.datas,

45    strip=False,

46    upx=True,

47    upx_exclude=[],

48    name='check',

49)
```

# 解释spec
我们先看最重要的几个参数

第7行:

很多时候我们会有很多自己写的依赖文件，pyinstaller会打包第三方库，但是不会打包我们自己写的，所以我们需要手动添加。

['check.py'] -> ['check.py','helper.py','utils.py','a.py','b.py']

第10行:
有些时候我们使用C编写部分代码，给Python调用这种情况，这时候应该把这部分文件包括进去，需要注意的是，以元组形式，不要直接写文件名字，注意下格式

datas=[] ->  datas=[("cmain.dll",".")]

第33行:

如果我们使用的是tk，pyqt这类自己具有GUI的第三方库构建的程序，通常我们不需要console，修改即可：

console=True -> console=False

到这里基本解释完了大部分重要参数，注意，这种方式打包的是文件夹形式，而非单个EXE文件，这种方式是最好的打包方式，但是并不一定是最适合的打包方式。

有些时候，我们需要打包成单个exe可执行文件，不希望出现很多其他文件，原因是不管是作为普通用户还是开发者，在文件夹里找exe虽然不累，但是多了一个步骤。如果是单个exe，那么用户可以随意放在任意位置打开，方便很多。

这里补充说明下：单个exe打包的一些问题，单个exe在执行的时候实际上是进行了一步自解压的操作，可以理解为，程序自己解压自己，会创建一个临时文件夹，结构和上面那种打包方式的结构一致。一般来讲，现在的处理器应付起来绰绰有余，但是这里涉及一个安全的问题，windows操作系统会对解压出来的二进制文件进行安全检查，这部操作会导致程序启动时间拉长。也就是我们使用的时候可以明显感受到程序启动有延迟。另外，由于程序自解压的临时文件夹，正常运行后是会自动清除的，但是如果程序异常那么临时文件夹会保留，当然这无关紧要，只是在这里提出。

再补充个名字：第28行，第48行，我们可以自行定义exe文件名，至于这两个分别代表什么名字，一试便知，无需多言。



# 生成单个exe的spec
`pyinstaller.exe --onefile .\check.py`

spec文件内容都差不多，可以参考上面的修改即可

# 如何写代码
其实这部分应该放到最前面来说，因为pyinstaller打包的原因，必须要考虑路径的问题。

例如：代码中需要加载一个json配置文件，该文件位于: /home/ubuntu/config.json

代码中直接使用 json.loads(r"/home/ubuntu/config.json") 这样的绝对路径，那么打包之后必定是有问题的，其它人使用的时候找不到这个文件，所以我们需要使用相对路径的方式，例如使用`basedir = os.path.dirname(__file__)`, 直接获取该文件的文件夹路径作为基路径，后续路径都在该路径上使用 join 进行拼接，这是在代码编写时候就需要考虑的问题。

再有就是导包的问题，尽量最小化导入，使用from 方式导入，用到了那个再导入那个方法，尽量不要使用*这种导入，这会让打包的时候体积过大。

# Pyinstaller总结
它不是一个最好的打包工具，但它是一个易上手的工具

它有很多的问题，但瑕不掩瑜

它的跨平台打包特性如果是你不需要的，那么多平台打包于你而言便毫无益处，一切以你的需求为准
