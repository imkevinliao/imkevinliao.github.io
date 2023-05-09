---
title: "culture"
date: 2023-05-09T16:01:06+08:00
draft: false
---
# 中华文化

# 起源
很早就在Github上看见了<https://github.com/chinese-poetry/chinese-poetry>这个仓库，当时觉得真的太棒了，那时候的我还不了解ORM，
只是知道有这么个东西，关于ORM的中文解释读了很多遍，懂了但也只是知道而已，并没有实际的体会。那时候的我还执着于mysql，对于sqlite不屑一顾。

那时候看到这么好的诗词文化库，第一个念头就是，要是能把它们存到本地数据库里面，那该多好啊，可以很方便查看，于是就开始吭哧吭哧搞了起来。

谁曾想，这一搞竟然搞了很长时间，并且还写了两个版本，因为第一版时间太久了，在操作数据库这部分，当时还去查找了各种优化方式，其中一种是不要单次提交，
而是一次性提交，再一个就是使用了多进程来加速，并且还配上了log来看大概需要多久，记得当初这个效率十分慢，跑一次大概要一个小时。代码会在最后给出。

mariadb 是我最喜欢的数据库，无他，只是因为它是开源免费的。由于对数据库的SQL语句并不是很熟悉，加上一直记得要注意SQL注入，于是查了些资料，
奈何最后写出来的代码还是一团糟，现在看起来，当初写的难免有些幼稚。

# 转折
处于对文化的热爱，很喜欢苏轼的词，`但远山长，云山乱，晓山青`，读来朗朗上口，相比于诗我更偏爱词。词里有李煜的梦中思故国，有辛弃疾的慷慨激昂，
有晏殊的娴雅情思，有李清照的怀乡悼亡，还有很多很多

也喜欢屈原的离骚，虽然时间上相隔了千余年，但力透古今的文字，就像是有一种魔力，跨越了千年的时空，直击到心底最深处，震颤了灵魂，注入血液之中，
翻涌流淌。

一晃过了很久，逛Github时候又发现了它，而此时的我已经了解sqlite，并且真正会运用ORM了，而这，令我大为震撼。

说来也是巧合，我在学习Flask的过程中，碰到了sqlalchemy，当时的是flask-sqlalchemy，认识到了modules的方式，正式这些巧合，让我突发联想，
于是便洋洋撒撒写下新的代码。彼时的我还没意识到，它能带给我多少惊喜。有了之前的经验，在写代码的时候先写了一个demo，然后便开始拆分成一个个模块，
使其进行组合，以便于复用。在拆分代码使其结构化的过程，加上对于sqlalchemy的理解，以及纯粹的目的，便有了现在的新代码。

sqlite也成为了我的选择，我放弃mariadb，不是因为它不好，也不是因为性能不如sqlite，只是因为sqlite方便，它是Python自带的。
很多时候，我们都没有做错什么，只是我们不合适罢了，如果一定要加上一个限定的话，我觉得是此时此刻不合适罢了。

生活就是这样，在什么都不懂得年纪，带着一腔热血，搞了半天，结果灰头土脸的宣布“胜利”而告终；当成长后，在有了曾经不曾有的实力后，
却丧失了当初的热忱和喜悦，关于从一小时四十五分钟到一小时三十分钟速度提升的兴奋感。

新的代码，仅仅花费一分钟就搞定了所有的事情，并且还把繁简转换给做了。速度提升了60倍，但是喜悦的感受不及当初十分之一，热爱依旧热爱，
只是少了当初那份激情，喜欢依旧喜欢，只是变得不再溢于言表，而是如品茶似的调剂生活。

# 尾章
我们正在失去，失去我们所失去的，失去，永久地失去

>行香子·过七里濑  
苏轼 〔宋代〕  
一叶舟轻，双桨鸿惊。水天清、影湛波平。鱼翻藻鉴，鹭点烟汀。过沙溪急，霜溪冷，月溪明。  
重重似画，曲曲如屏。算当年、虚老严陵。君臣一梦，今古空名。但远山长，云山乱，晓山青。  

# 代码
## 第一版代码
```python
import json
import logging
import os
import time

import mariadb

# config path
root_path = r'D:\chinese-poetry-master'
tangshi_path = os.path.join(root_path, r'json')
songci_path = os.path.join(root_path, r'ci')
huajian_path = os.path.join(root_path, r'wudai\huajianji')
shijing_path = os.path.join(root_path, r'shijing')

# config mariadb connect
pool = mariadb.ConnectionPool(
    pool_name='my_pool',
    pool_size=4,
    host='127.0.0.1',
    user='root',
    password='root',
    database='poem',
    autocommit=True,
)
# config log
t = time.localtime(time.time())
cur_time = f'{t.tm_year:04}{t.tm_mon:02}{t.tm_mday:02}'
logging.basicConfig(format="%(asctime)s %(levelname)s [line:%(lineno)d] %(message)s",
                    datefmt="%Y-%m-%d %H:%M:%S(%p)",
                    level=logging.DEBUG,
                    handlers=[logging.FileHandler(filename=cur_time + ".log", encoding='utf-8', mode='a+')])


def get_paths(path) -> list:
    file_paths = []
    files = os.listdir(path)
    for file in files:
        if '.json' in file:
            file_paths.append(os.path.join(path, file))
    if not file_paths:
        logging.info(f"json file is None: {path}")
    return file_paths


def save_to_mariadb(file_path, mtype=None):
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    flag = True
    if mtype == 'songci':
        for i in data:
            m_rhythmic, m_author, m_paragraphs = i["rhythmic"], i["author"], ''.join(i["paragraphs"])
            cursor.execute("select * from ci where rhythmic = ? and author = ? and  paragraphs = ?",
                           (m_rhythmic, m_author, m_paragraphs))
            if cursor.rowcount == 0:
                cursor.execute("INSERT INTO ci (rhythmic,author,paragraphs) VALUES (?, ?, ?)",
                               (m_rhythmic, m_author, m_paragraphs))
            elif cursor.rowcount != 1:
                if flag:
                    logging.info(f"Duplicate records exist in the database. file path is {file_path}")
                    flag = False
                [logging.info(i) for i in cursor]
        ...
    elif mtype == 'author_ci' or mtype == 'author_shi':
        for i in data:
            if mtype == 'author_ci':
                m_description, m_name, m_short_description = i["description"], i["name"], i["short_description"]
                cursor.execute("select * from author where full_desc = ? and author = ? and  short_desc = ?",
                               (m_description, m_name, m_short_description))
                if cursor.rowcount == 0:
                    cursor.execute("INSERT INTO author (author,full_desc,short_desc) VALUES (?, ?, ?)",
                                   (m_name, m_description, m_short_description))
                elif cursor.rowcount != 1:
                    if flag:
                        logging.info(f"Duplicate records exist in the database.file path is {file_path}")
                        flag = False
                    [logging.info(i) for i in cursor]
            elif mtype == 'author_shi':
                m_desc, m_name, m_id = i["desc"], i["name"], i["id"]
                cursor.execute("select * from author where full_desc = ? and author = ? and  id = ?",
                               (m_desc, m_name, m_id))
                if cursor.rowcount == 0:
                    cursor.execute("INSERT INTO author (author,full_desc,self_id) VALUES (?, ?, ?)",
                                   (m_name, m_desc, m_id))
                elif cursor.rowcount != 1:
                    if flag:
                        logging.info(f"Duplicate records exist in the database.file path is {file_path}")
                        flag = False
                    [logging.info(i) for i in cursor]
    elif mtype == 'tangshi':
        for i in data:
            m_author, m_paragraphs, m_title, m_id = i["author"], ''.join(i["paragraphs"]), i["title"], i["id"]
            cursor.execute("select * from shi where author = ? and paragraphs = ? and  title = ? and self_id = ?",
                           (m_author, m_paragraphs, m_title, m_id))
            if cursor.rowcount == 0:
                cursor.execute("INSERT INTO shi (author,paragraphs,title,self_id) VALUES (?, ?, ?,?)",
                               (m_author, m_paragraphs, m_title, m_id))
            elif cursor.rowcount != 1:
                if flag:
                    logging.info(f"Duplicate records exist in the database. file path is {file_path}")
                    flag = False
                [logging.info(i) for i in cursor]
    else:
        logging.debug("type out of range")


def json_file(file_paths: list):
    for path in file_paths:
        logging.debug(f"Start processing file:{path}")
        if os.path.split(path)[0] == tangshi_path:
            if "author" in os.path.basename(path):
                save_to_mariadb(path, 'author_shi')
                ...
            elif "poet" in os.path.basename(path):
                save_to_mariadb(path, 'tangshi')
                ...
        elif os.path.split(path)[0] == songci_path:
            if os.path.basename(path) == "author.song.json":
                save_to_mariadb(path, 'author_ci')
            elif "ci.song" in os.path.basename(path):
                save_to_mariadb(path, 'songci')
            else:
                logging.debug(f"the file: {os.path.basename(path)} out of program")
                ...
        else:
            logging.warning("Exceeds the processing scope of the program. Check whether the problem exists.")


def create_table(create=True) -> None:
    """
    include create and drop
    :param create: if you need drop table, make create false, be careful!!!
    :return:None
    """
    table_names = ['shi', 'ci', 'author']
    commands = []
    create_shi = """
        create table if not exists shi(
        id int not null auto_increment,
        author varchar(255),
        paragraphs text,
        title varchar(255), 
        self_id varchar(255),
        dynastic varchar(255),
        primary key (id)
    ); 
    """
    create_ci = """
        create table if not exists ci(
            id int not null auto_increment,
            author varchar(255),
            paragraphs text,
            rhythmic varchar(255), 
            primary key (id)
        ); 
        """
    create_author = """
        create table if not exists author(
            id int not null auto_increment,
            author varchar(255),
            full_desc text,
            short_desc text,
            self_id varchar(255),
            dynastic varchar(255),
            primary key (id)
        ); 
    """
    commands.append(create_shi)
    commands.append(create_ci)
    commands.append(create_author)
    for i in commands:
        try:
            cursor.execute(i)
        except mariadb.Error as e:
            logging.error(f"Error create table {i}: {e}")
    ...
    if not create:
        for i in table_names:
            command = "drop table " + i
            try:
                cursor.execute(command)
                logging.warning(command)
            except mariadb.Error as e:
                logging.error(f"Error drop table {i}: {e}")


def core_exec():
    json_file(get_paths(tangshi_path))
    json_file(get_paths(songci_path))
    ...


if __name__ == '__main__':
    conn = pool.get_connection()
    cursor = conn.cursor()
    create_table()
    core_exec()
    cursor.close()
    conn.close()
    ...
```
## 第二版代码
```python
import json
import logging
import multiprocessing
import os
import sys
import time
from multiprocessing import Manager

import mariadb
import opencc

# global config
isDirectInsert = True  # check the value if exists, before insert,Recommend True.
isSimplifiedChinese = True  # origin data is Traditional Chinese,Recommend True.
isDropTable = False  # if true,table will be dropped,include data of table,Recommend False
INSERT_NUMBER = 500  # Recommend 500
isMultiProcess = True
shi_path = r"D:\chinese-poetry-master\json"
ci_path = r"D:\chinese-poetry-master\ci"

# config mariadb connect
pool = mariadb.ConnectionPool(
    pool_name='pools',
    pool_size=4,
    host='127.0.0.1',
    user='root',
    password='root',
    database='test2',
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
        logging.debug(f'Function {func.__name__} Took {int(total_time) // 3600} hours '
                      f'{int(total_time // 60)} minutes {int(total_time % 60)} seconds')
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
    获取指定路径下符合条件的文件的绝对路径
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


def error(value):
    print(f'error:{value}')


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


def log_init():
    logging.info("Program start...")
    logging.info(f"params:\nisDirectInsert is:{isDirectInsert};isSimplifiedChinese is:{isSimplifiedChinese}\n"
                 f"isDropTable is:{isDropTable};INSERT_NUMBER is:{INSERT_NUMBER}\n"
                 f"shi_path is:{shi_path};ci_path is{ci_path}")


if __name__ == '__main__':
    log_init()
    core_exec()
```
## 新代码 sqlalchemy with sqlite
```python
import json
import os
import time
from os.path import join

import opencc
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session

from modules import Base, YuanQu, HuaJianJi, ChuCi, ShiJing, LunYu, SiShuWuJing, SongCi, TangShi, TangShi_Simple


def create_table(is_force=False):
    if is_force:
        Base.metadata.drop_all(engine)
        Base.metadata.create_all(engine)
    else:
        Base.metadata.create_all(engine,checkfirst=True)
    

class JsonData(object):
    def __init__(self,path,besides=[]):
        self.path = path
        self.besides = besides
    def get_files(self):
        files = os.listdir(self.path)
        files_new = [os.path.join(self.path, _) for _ in files if _.endswith(".json")]
        return files_new
    @staticmethod
    def filter_files(files, besides: list = [], regex: str = None):
        def check_file(file):
            is_in = False
            for check in besides:
                if check in file:
                    is_in = True
                    break
            return is_in
        result = []
        for json_file in files:
            # 排除文件路径干扰，只取文件名检测
            json_file_name = os.path.basename(json_file)
            ret = check_file(json_file_name)
            if not ret:
                result.append(json_file)
        if regex:
            ...
        return result
    @staticmethod
    def get_data(path):
        with open(path, 'r', encoding="utf-8") as f:
            json_data = json.load(f)
        return json_data
    def get_all_data(self):
        files = self.get_files()
        files_new = self.filter_files(files,besides=self.besides)
        _temp = []
        for file in files_new:
            json_data = self.get_data(file)
            for d in json_data:
                _temp.append(d)
        return _temp
    def run(self):
        return self.get_all_data()


def yuanqu(path,besides,_session:Session):
    datas = JsonData(path,besides=besides).run()
    for data in datas:
        dynasty = data.get("dynasty", "None")
        author = data.get("author", "None")
        paragraphs = data.get("paragraphs", "None")
        paragraphs = "".join(paragraphs)
        title = data.get("title", "None")
        _session.add(YuanQu(dynasty=dynasty, author=author, paragraphs=paragraphs, title=title))

def huajian(path,besides,_session:Session):
    datas = JsonData(path,besides=besides).run()
    for data in datas:
        title = data.get("title", "None")
        paragraphs = data.get("paragraphs", "None")
        paragraphs = "".join(paragraphs)
        author = data.get("author", "None")
        rhythmic = data.get("rhythmic","None")
        notes = data.get("notes","None")
        notes = "".join(notes)
        _session.add(HuaJianJi(rhythmic=rhythmic, author=author, paragraphs=paragraphs, title=title, notes=notes))


def quantangshi(path,besides,_session:Session,is_simplified=False):
    datas = JsonData(path, besides=besides).run()
    converter = opencc.OpenCC('t2s')
    for data in datas:
        author = data.get("author", "None")
        paragraphs = data.get("paragraphs", "None")
        paragraphs = "".join(paragraphs)
        note = data.get("note","None")
        note = "".join(note)
        title = data.get("title", "None")
        _session.add(TangShi(author=author, paragraphs=paragraphs,note=note,title=title))
        if is_simplified:
            _session.add(TangShi_Simple(author=converter.convert(author), paragraphs=converter.convert(paragraphs),
                                        note=converter.convert(note), title=converter.convert(title)))

def sishuwujing(path,besides,_session:Session):
    datas = JsonData(path,besides=besides).run()
    for data in datas:
        if not isinstance(data,dict):
            continue
        chapter = data.get("chapter", "None")
        paragraphs = data.get("paragraphs", "None")
        paragraphs = "".join(paragraphs)
        _session.add(SiShuWuJing(chapter=chapter, paragraphs=paragraphs))
    pass


def songci(path,besides,_session:Session):
    datas = JsonData(path,besides=besides).run()
    for data in datas:
        author = data.get("author", "None")
        paragraphs = data.get("paragraphs", "None")
        paragraphs = "".join(paragraphs)
        rhythmic = data.get("rhythmic","None")
        _session.add(SongCi(author=author, paragraphs=paragraphs, rhythmic=rhythmic))
    pass


def chuci(path,besides,_session:Session):
    datas = JsonData(path,besides=besides).run()
    for data in datas:
        section = data.get("section", "None")
        author = data.get("author", "None")
        title = data.get("title", "None")
        content = data.get("content","None")
        content = "".join(content)
        _session.add(ChuCi(section=section, author=author, content=content, title=title))


def lunyu(path,besides,_session:Session):
    datas = JsonData(path,besides=besides).run()
    for data in datas:
        chapter = data.get("chapter","None")
        paragraphs = data.get("paragraphs", "None")
        paragraphs = "".join(paragraphs)
        _session.add(LunYu(chapter=chapter, paragraphs=paragraphs))
    pass


def shijing(path,besides,_session:Session):
    datas = JsonData(path,besides=besides).run()
    for data in datas:
        section = data.get("section", "None")
        title = data.get("title", "None")
        chapter = data.get("chapter","None")
        content = data.get("content","None")
        content = "".join(content)
        _session.add(ShiJing(section=section, chapter=chapter, content=content, title=title))


def core(_session:Session):
    current_dir = os.path.dirname(__file__)
    basedir = os.path.dirname(current_dir)
    
    yuanqu_dir = join(basedir,f"元曲")
    hujian_dir = join(basedir,f"五代诗词{os.sep}huajianji")
    chuci_dir = join(basedir,f"楚辞")
    shijing_dir = join(basedir,f"诗经")
    lunyu_dir = join(basedir,f"论语")
    sishuwujing_dir = join(basedir,f"四书五经")
    songci_dir = join(basedir,f"宋词")
    quantangshi_dir = join(basedir,f"全唐诗")
    
    yuanqu(_session = _session,path=yuanqu_dir, besides=[])
    huajian(_session=_session,path=hujian_dir,besides=['huajianji-0-preface.json'])
    sishuwujing(_session = _session,path=sishuwujing_dir, besides=[])
    chuci(_session = _session,path=chuci_dir, besides=[])
    lunyu(_session = _session,path=lunyu_dir, besides=[])
    shijing(_session = _session,path=shijing_dir, besides=[])
    songci(_session=_session, path=songci_dir, besides=["author.song.json"])
    quantangshi(_session=_session, path=quantangshi_dir, besides=["authors", "唐诗", "表面结构字"],is_simplified=True)
    
    
if __name__ == '__main__':
    s = time.time()
    url = f"""sqlite:///{os.path.join(os.path.dirname(__file__), "culture.db")}"""
    engine = create_engine(url)
    Session = sessionmaker(engine)
    session = Session()
    create_table(is_force=True)
    core(_session=session)
    session.commit()
    session.close()
    e = time.time()
    print(f"spend time {int(e-s)} seconds")
```
```python
from sqlalchemy import Column, Integer, Text
from sqlalchemy import String
from sqlalchemy.orm import declarative_base

Base = declarative_base()

class YuanQu(Base):
    __tablename__ = "YuanQu"
    id = Column(Integer, primary_key=True)
    dynasty = Column(String(10))
    author = Column(String(20))
    paragraphs = Column(Text)
    title = Column(String(100))
    
class HuaJianJi(Base):
    __tablename__ = "HuaJianJi"
    id = Column(Integer, primary_key=True)
    title = Column(String(100))
    paragraphs = Column(Text)
    author = Column(String(20))
    rhythmic = Column(String(20))
    notes = Column(Text)

class ChuCi(Base):
    __tablename__ = "ChuCi"
    id = Column(Integer, primary_key=True)
    title = Column(String(100))
    section = Column(String(20))
    author = Column(String(20))
    content = Column(Text)

class ShiJing(Base):
    __tablename__ = "Shijing"
    id = Column(Integer, primary_key=True)
    title = Column(String(100))
    chapter = Column(String(20))
    section = Column(String(20))
    content = Column(Text)
    
class LunYu(Base):
    __tablename__ = "LunYu"
    id = Column(Integer, primary_key=True)
    chapter = Column(String(20))
    paragraphs = Column(Text)
class SiShuWuJing(Base):
    __tablename__ = "SiShuWuJing"
    id = Column(Integer, primary_key=True)
    chapter = Column(String(20))
    paragraphs = Column(Text)

class SongCi(Base):
    __tablename__ = "SongCi"
    id = Column(Integer, primary_key=True)
    author = Column(String(20))
    paragraphs = Column(Text)
    rhythmic = Column(String(100))

class TangShi(Base):
    __tablename__ = "TangShi"
    id = Column(Integer, primary_key=True)
    author = Column(String(20))
    paragraphs = Column(Text)
    note = Column(Text)
    title = Column(String(100))
    
class TangShi_Simple(Base):
    __tablename__ = "TangShi_Simple"
    id = Column(Integer, primary_key=True)
    author = Column(String(20))
    paragraphs = Column(Text)
    note = Column(Text)
    title = Column(String(100))
```
