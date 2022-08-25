---
title: "python_mariadb2"
date: 2022-08-11T16:59:05+08:00
draft: false
---
# 书接上回
代码写多了就会发现，单纯的写很简单，难的是写出来的代码够优雅并且容易维护。是的，基于代码维护的考虑，才有了接下来新代码。

之前有提到过，原来的代码还存在一些问题，具体的问题如下：

1. 维护困难
2. 源数据中诗部分采用的是繁体中文，所以增加了简繁转换功能
3. 效率问题

# 起承转合
Q1:维护的问题，也就是一直以来思考的代码优雅之道，直接写很简单，难的是后续的维护。维护关系到一个月后自己是否还能读懂

Q2:关于简繁转换，看了一些库最后决定用opencc，其实用什么不重要，重要的是这个影响了我对于表结构的思考。起初想的是将源数据和简体化后的数据一同保存为同一条记录，但是后来发现，原来不止是诗歌内容是繁体，连标题和作者都是繁体字，然后我就呆住了，我当然可以多加几个字段，这是最简单的方式，但是我放弃了。对源数据的完整保存我认为是非常必要的，所以我当时一直思考的是必须保留源数据。直到在优化代码的时候，我想到了过度封装，忽然就释然了。从实际使用角度来看，我不会去看繁体的诗词，所以不妨直接配置一个简繁开关，也不去想太多。

Q3：以前写爬虫的时候，我记得最多也就是一张表爬了两三万条数据吧，一般一张表六七千。之前做爬虫还遇到过sql注入的问题，从那之后我就学会了数据库插入的新写法，这个习惯也保留至今。在插入数据前查询是否存在，如果不存在则插入，但是当表中的数据量达到十万级别的时候，每一次插入都要进行检查效率太低了，在提高效率上，开始了新一轮的思考。

Q3:为什么要一次插入一条数据呢？于是乎我开始改写代码，一次插入多条，使用execute，折腾半天才知道应该使用executemany。如果有个人和我提一嘴可以省去我不知道多少走错路的时间。当我使用executemany时候出现了问题，报错提示我不能运行这个命令，Google了半天，还是一无所获，于是只能去看mariadb的API文档说明，顺便把其他可能涉及到的API也都看了一遍，于是才有了眉目。

# Code
```python3
import json
import logging
import os
import sys
import time

import mariadb
import opencc

# global config
isDirectInsert = True  # check the value if exists, before insert,Recommend True.
isSimplifiedChinese = True  # origin data is Traditional Chinese,Recommend True.
isDropTable = True  # if true,table will be dropped,include data of table,Recommend False
INSERT_NUMBER = 1000
shi_path = r"D:\chinese-poetry-master\json"
ci_path = r"D:\chinese-poetry-master\ci"

# config mariadb connect
pool = mariadb.ConnectionPool(
    pool_name='pools',
    pool_size=4,
    host='127.0.0.1',
    user='root',
    password='root',
    database='poem',
)

# config log encoding 参数需要 python3.9及以上版本，配置目的为了防止logging中文乱码
LOG_FORMAT = "%(asctime)s %(levelname)s [line:%(lineno)d] %(message)s"
LOG_DATE_FORMATE = "%Y-%m-%d %H:%M:%S(%p)"
LOG_FILENAME = "poem.log"
logging.basicConfig(format=LOG_FORMAT, datefmt=LOG_DATE_FORMATE, level=logging.DEBUG, filename=LOG_FILENAME,
                    encoding="utf-8")


class Table(object):
    def __init__(self, table_name: str, primary_key: str, column_name: list, column_desc: list,
                 column_info: dict = None):
        self.table_name = table_name
        self.primary_key = primary_key
        self.column_name = column_name
        self.column_desc = column_desc
        if column_info:
            self.column_info = column_info
        else:
            self.column_info = dict(zip(column_name, column_desc))

    def show(self):
        sql_str = ""
        for key, value in self.column_info.items():
            sql_str = sql_str + key + " " + value + ","
        table = f"""
            create table if not exists {self.table_name}(
                {sql_str}
                primary key ({self.primary_key})
            );
        """
        print(table)


def timeit(func):
    def timeit_wrapper(*args, **kwargs):
        start_time = time.perf_counter()
        result = func(*args, **kwargs)
        end_time = time.perf_counter()
        total_time = end_time - start_time
        # logging.debug(f'Function {func.__name__} args:{args} kwargs:{kwargs} Took {total_time:.4f} seconds')
        logging.debug(f'Function {func.__name__} '
                      f'Took {int(total_time)//3600} {int(total_time//60)} minutes {int(total_time%60)} seconds')
        return result

    return timeit_wrapper


def create_table(table_name: str, primary_key: str, column_name: list, column_desc: list):
    column_info = dict(zip(column_name, column_desc))
    sql_str = ""
    for key, value in column_info.items():
        sql_str = sql_str + key + " " + value + ","
    create = f"""
        create table if not exists {table_name}(
            {sql_str}
            primary key ({primary_key})
        );
    """
    logging.debug(f"create info {create}")
    return create


def drop_table(table_name):
    drop = "drop table " + table_name
    return drop


def t2s(data):
    """
    Traditional to Simplified.
    Data type can be list, str, tuple.
    input data == return data
    """
    cc = opencc.OpenCC("t2s.json")
    if isinstance(data, list):
        result = []
        for i in data:
            result.append(cc.convert(i))
        return result
    elif isinstance(data, str):
        result = cc.convert(data)
        return result
    elif isinstance(data, tuple):
        result = []
        for i in data:
            result.append(cc.convert(i))
        result = tuple(result)
        return result
    else:
        logging.debug("args type out of range!!!")


def get_json_paths(root_path) -> list:
    """
    获取指定路径下符合条件文件的绝对路径
    :param root_path:
    :return:
    """
    dirs = os.listdir(root_path)
    filter_paths = []
    for file in dirs:
        if '0' in file and 'json' in file:  # 唐诗&宋词
            filter_paths.append(os.path.join(root_path, file))
    if not filter_paths:
        logging.warning(f"No file that meets the rule exists in the directory :{root_path}")
    logging.debug(f"after filter path is {filter_paths}")
    return filter_paths


def get_json_data(json_path):
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    return data


def set_table(table_name):
    table_name = table_name
    if table_name == 'shi':
        primary_key = 'id'
        column_name = ["id", "title", "author", "dynastic", "content", "self_id", "simple"]
        column_desc = ["int not null auto_increment", "varchar(255)", "varchar(255)", "varchar(255)", "text",
                       "varchar(255)", "varchar(255)"]
    elif table_name == 'ci':
        primary_key = 'id'
        column_name = ["id", "title", "author", "dynastic", "content"]
        column_desc = ["int not null auto_increment", "varchar(255)", "varchar(255)", "varchar(255)", "text"]
        ...
    else:
        sys.exit()
    tb = Table(table_name, primary_key, column_name, column_desc)
    return tb


@timeit
def save_to_mariadb(tb: Table, paths: list):
    conn = pool.get_connection()
    cursor = conn.cursor()
    if isDropTable:
        cursor.execute(drop_table(tb.table_name))
    cursor.execute(create_table(tb.table_name, tb.primary_key, tb.column_name, tb.column_desc))
    for file_path in paths:
        logging.info(f"Processing file:{file_path}")
        data = get_json_data(file_path)
        mult_data = []
        for index, value in enumerate(data):
            if tb.table_name == "shi":
                column_names = (tb.column_name[1], tb.column_name[2], tb.column_name[4], tb.column_name[5])
                column_value = (value["title"], value["author"], ''.join(value["paragraphs"]), value["id"])
            elif tb.table_name == "ci":
                column_names = (tb.column_name[1], tb.column_name[2], tb.column_name[4])
                column_value = (value["rhythmic"], value["author"], ''.join(value["paragraphs"]))
            else:
                sys.exit()
            if isSimplifiedChinese:
                column_value = t2s(column_value)

            column_fills = f"({(len(column_names) - 1) * '?,' + '?'})"
            column_str = ''
            for i, j in enumerate(column_names):
                if i == len(column_names) - 1:
                    column_str = column_str + j
                else:
                    column_str = column_str + j + ","
            column_str = "(" + column_str + ")"
            if INSERT_NUMBER > 1:
                mult_data.append(column_value)
                if (len(mult_data) == INSERT_NUMBER) or (index == (len(data) - 1)):
                    cursor_new = conn.cursor()
                    cursor_new.executemany(f"insert into {tb.table_name} {column_str} values {column_fills}", mult_data)
                    cursor_new.close()
                    mult_data = []
            else:
                cursor.execute(f"insert into {tb.table_name} {column_str} values {column_fills}", column_value)
                logging.debug(f"""sql command is "insert into {tb.table_name} {column_str} values {column_fills}" """)

    conn.commit()
    conn.close()


def core_exec():
    save_to_mariadb(set_table("ci"), get_json_paths(ci_path))
    save_to_mariadb(set_table("shi"), get_json_paths(shi_path))


def log_init():
    logging.info("Program start...")
    logging.info(f"params:\nisDirectInsert is:{isDirectInsert};isSimplifiedChinese is:{isSimplifiedChinese}\n"
                 f"isDropTable is:{isDropTable};INSERT_NUMBER is:{INSERT_NUMBER}\n"
                 f"shi_path is:{shi_path};ci_path is{ci_path}")


if __name__ == '__main__':
    log_init()
    core_exec()
```
# 一波三折
对于效率这件事，再怎么追求极致都不为过，每省下来的一秒钟，都是对自己代码的一次肯定。

当改变插入方式，从每次插入一条到插入多条，速度有了明显的提升。之前是自动commite，也改成了手动，能省一点是一点。也为了提高效率尝试使用装饰器测算每个函数的运行时间，再根据日志来尽可能提高每个函数的运行效率，但是这部分还是没有写好。

在代码优化方面，一开始试图将创建表 和 插入表 需要使用到的列抽象出来，但是后面发现并不是很好写。又想到过度封装，想想还是算了。

只把诗词两部分写好了，一开始还打算把数据库的创建也包含在代码里，但是感觉这样子的话封装的太过了，实现并不复杂，负责的是整体的设计思考。设计与思考又来需要实际使用，实际操作得到的信息来做出判断。

目前算是比较满意的结果了，虽然还可以改进，但是更多的还是需要思考，写代码很简单，难的是写的优雅，任重而道远。去重的思路：一种是在插入时候检查，另一种是先插入后去重。

维护是一件很重要的事！这次也强行插入log模块，感受到在低代码量下表现并不是很显著，可能要在大项目中会有更好的发挥空间。

------------------------------------------------------
更新：
后面想到用多进程来提高效率，贴一下更新的部分吧
```python3
def core_exec():
    if isMultiProcess:
        logging.info("now multiprocess:")
        multi_core = multiprocessing.Pool(processes=3)
        multi_core.apply_async(save_to_mariadb, args=(set_table("ci"), get_json_paths(ci_path)), error_callback=error)
        multi_core.apply_async(save_to_mariadb, args=(set_table("shi"), get_json_paths(shi_path)), error_callback=error)
        multi_core.close()
        multi_core.join()
    else:
        save_to_mariadb(set_table("ci"), get_json_paths(ci_path))
        save_to_mariadb(set_table("shi"), get_json_paths(shi_path))
```
用了多进程后，忽然发现代码从头到尾就错了，设计之初就应该采取多进程，如今后悔也晚了。

如果设计之初就考虑到这些的话，再把规范弄好，代码维护起来应该会比较方便。这次还有一点点小小的领悟，就是debug时候需要值的打印，应该设计一个较为普遍的打印方式，debug真的非常重要在查找问题的时候，最近工作中就遇到log的问题，因为log没有统一的维护，导致多个模块需要打印log的时候配置极其不方便，一些参数的值也随着代码不断地修改，导致log可能存在问题。

对于效率，每一秒的提高都是一种成功
