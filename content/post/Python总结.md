---
title: "Python总结"
date: 2021-11-10T22:03:35+08:00
draft: false
---
# 序章
今天突然翻看到很早之前做的关于Python的小结，忽然间就很感慨，那段时间写的东西最后都浓缩为短短的几行代码，对于写代码这件事情，早就意识到了。只要一段时间不写，就会变得生疏，所以当时特意留下笔记，方便以后什么时候重新上手的时候可以很快熟悉代码。
大部分是当时写爬虫时候留下的笔记，记得当时还把Java的笔记也整理了一下。

------------------

# 代理的写法
```
import urllib.request as request
import requests
proxies = {
    'https': 'https://127.0.0.1:10809',
    'http': 'http://127.0.0.1:10809'
}
headers = {
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36'
}
print('--------------使用urllib--------------')
google_url = 'https://www.google.com'
opener = request.build_opener(request.ProxyHandler(proxies))
request.install_opener(opener)
req = request.Request(google_url, headers=headers)
response = request.urlopen(req)
print(response.read().decode())
print('--------------使用requests--------------')
response = requests.get(google_url, proxies=proxies)
print(response.status_code)
```
# 正则的使用
``` 
第一种:
import re
m_str=r"http://img.itmtu.com/mm/d/dounianglishi/NO.011/0003.jpg"
regex=r"(?<=/)\d+"
result=re.search(regex,m_str).group()
print(result)
第二种:
file= open(r'e:/test.txt','r',encoding='utf-8')
content = file.read()
regex1='regex1'
regex2='regex2'
m1=re.findall(regex1,content,re.M)
m2=re.search(regex1,content,re.M)
reg_content=re.sub(regex1,'',content)
reg_content=re.sub(regex2,'',reg_content)
print(reg_content)
if m1:
    for m in m1:
        print(m)
else:
    print('No match')
```
# 文件流 open
```
f = open("test.txt",'a+',encoding='utf-8')
line = f.readline()
while line:
    print (line)
    line = f.readline()
f.close()
补充说明:open方式打开文件最少需要路径一个参数即可.
```
# 获取for循环中数组序列下标的获取
```
a=list['yi','er','san','si','wu']
for index,var in enumerate(a,1):
    print(var)
    print(index)
补充说明:enumerat(a,1)中的1指的是下标从1开始,不写则默认下标从0开始,index为下标.
```
# requests的常用方法
```
import requests
response = requests.get(url, headers=headers, verify=False, proxies=None, timeout=5)
if response.status_code == 200
从response获取编码方式并以此解码.
enconding = requests.utils.get_encodings_from_content(response.text)
html=response.content.decode(enconding[0])
补充说明:response.text或response.content.decode('utf-8')都可以.
```
# Lxml 
```
from lxml import etree,html
tree=etree.HTML(response.text)
title=tree.xpath('//*[@id="content"]/div/div/div[1]/h3/text()')
```
# BeautifulSoup
```
from bs4 import BeautifulSoup
from lxml import etree
html=response.text
soup=BeautifulSoup(html,'lxml') 
print(soup.get_text())
titles=soup.find_all('h1',attrs={'class':'entry-title'})
text=soup.find('h1',attrs={'class':'entry-title'})
for title in titles:
    print(title.get_text())
```
# 连接数据库 mysql
```
connect = pymysql.Connect(
    host='localhost',
    port=3306,
    user='root',
    passwd='root',
    db='kevin',
    charset='utf8'
)
获取游标
cursor = connect.cursor()
插入数据
sql = "INSERT INTO Test(user_name,user_password,num) VALUES ( '%s', '%s', %.2f )"
item = ('悠然', '134582345678', 2000.58)
cursor.execute(sql % item)
connect.commit()
print('成功插入', cursor.rowcount, '条数据')
修改数据
sql = "UPDATE Test SET title = '标题' WHERE user_name = '悠然' "
cursor.execute(sql)
connect.commit()
print('成功修改', cursor.rowcount, '条数据')
查询数据
sql = "SELECT * FROM Test WHERE user_name='悠然' "
cursor.execute(sql)
for row in cursor.fetchall():
    print(row)
print('共查找出', cursor.rowcount, '条数据')
删除数据
sql = "DELETE FROM test WHERE user_name='悠然'"
cursor.execute(sql)
connect.commit()
print('成功删除', cursor.rowcount, '条数据')
事务处理
sql_1 = "UPDATE trade SET saving = saving + 1000 WHERE account = '18012345678' "
sql_2 = "UPDATE trade SET expend = expend + 1000 WHERE account = '18012345678' "
sql_3 = "UPDATE trade SET income = income + 2000 WHERE account = '18012345678' "
try:
    cursor.execute(sql_1)  #储蓄增加1000
    cursor.execute(sql_2)  #支出增加1000
    cursor.execute(sql_3)  #收入增加2000
except Exception as e:
    connect.rollback()  #事务回滚
    print('事务处理失败', e)
else:
    connect.commit()    #事务提交
    print('事务处理成功', cursor.rowcount)
cursor.close()
connect.close()
```
# selenium
```
from selenium import webdriver
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException #隐式等待
from selenium.webdriver.common.action_chains import ActionChains #鼠标点击
option=webdriver.ChromeOptions()
option.add_argument('--disable-infobars') #禁止显示"Chrome 正在受到自动化软件控制"
option.add_argument('user-data-dir=D:\ChromeDown\Temp') #禁止data参数出现
option.add_argument('--start-maximized') #driver.maximize_window() 效果类似.
option.binary_location =r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" #手动指定浏览器位置
option.add_argument('user-agent="MQQBrowser/26 Mozilla/5.0 (Linux; U; Android 2.3.7; zh-cn; MB200 Build/GRJ22; CyanogenMod-7) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"')
option.add_argument('--no-sandbox') #以最高权限运行
option.add_argument('--headless')   #无头模式
option.add_argument('blink-settings=imagesEnabled=false')  #不加载图片, 提升速度
option.add_extension('d:\crx\AdBlock_v2.17.crx')  #添加crx插件
option.add_argument("--disable-javascript") #禁用JavaScript
driver=webdriver.Chrome(executable_path='C:\Program Files (x86)\Google\Chrome\Application\chromedriver.exe')
driver=webdriver.Chrome(options=option)  # 创建driver
driver.implicitly_wait(15) #隐式等待(全局)
driver.get("https://www.baidu.com")
driver.quit(),driver.close()
简单用法
driver.find_elements_by_xpath('//*[@class="article___1nKEd"]/div[1]/p/img').get_attribute('href')
title=driver.find_element_by_xpath('//*[@id="content"]/div/div/div[1]/h3').get_attribute('textContent')
content=driver.find_element_by_xpath('//*[@id="content"]/div/div/div[2]/div').text
driver.find_element_by_xpath('//*[@id="masthead"]/div[2]/div/div/div/div[3]/div[2]/button[1]').click()
driver.find_element_by_xpath('//*[@id="sign-form"]/div/div[2]/div[2]/form/div[1]/label[1]/input').send_keys('2552712328@qq.com')
until里面是期待出现的条件,最好用try,except. 所有的期待方法都在selenium.webdriver.support.expected_conditions类里
element = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "myDynamicElement")) 
wait = WebDriverWait(driver, 10), element = wait.until(element_has_css_class((By.ID, 'myNewInput'), "myCSSClass"))
wait = WebDriverWait(driver, 10), element = wait.until(EC.element_to_be_clickable((By.ID, 'someid')))
```
# log 日志
```
import logging
logging.basicConfig(level = logging.DEBUG,format = '%(asctime)s - %(name)s -%(filename)s[line:%(lineno)d] - %(levelname)s - %(message)s') 
filename=r'my.log'
logging.debug(u'%s'%'ok,debug')
logging.info('提示:')
logging.debug(u"调试")
logging.info(u"执行打印功能")
logging.warning(u"警告")
logging.error(u"错误")
logging.critical(u"致命错误")
```
补充说明:logging.basicConfig里面的level设置输出日记等级,logging.NOTSET为全输出,logging.INFO不会输出DEBUG级别的内容.filename='mylog.log'加上这个设置就会输出到文件中.
