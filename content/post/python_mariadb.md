---
title: "python_mariadb"
date: 2022-08-02T14:17:09+08:00
draft: false
---
# 倾盖如故
偶尔翻翻github的推荐，看到了<https://github.com/chinese-poetry/chinese-poetry>这样一个项目，诗词嗯，很棒，忽然就萌生了把玩的想法，于是也就有了这篇文章的开始。mariadb一直是我很喜欢的软件，工作以后越来越喜欢开源的一些工具了，用起来没有麻烦。

# 奇思妙想
起初的时候，想法很简单也很纯粹，就是把项目中的json文件的数据保存到数据库中。嗯，就是最简单的把它存进去，我也没想到会出来很多很多的问题。最初始版本的代码已经不见了，那时候连接mariadb的写法还是直接从官网默认的方式写的，后面发现需求不断地增加，代码越来越乱，做了一点改进，但好像并没有什么特别的地方，只是优化出了第一版，也暴露了一些没有考虑过的问题。完整代码如下：
```python3
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
