---
title: "Scrapy"
date: 2020-12-19T21:30:26+08:00
---

Scrapy创建项目:
~~~
    scrapy startproject ScrpyDirection
    cd ScrapyDirection
    scrapy genspider -t crawl myspider www.baidu.com #创建全站爬虫,这种创建方式下myspider.py文件中已近包含items.py直接用就好了
    scrapy genspider myspider www.baidu.com #创建 一般/普通 爬虫
~~~
Scrapy快速启动:(创建start.py文件)
~~~
    os.system('cls') # 终端清屏
    os.chdir( r"D:\SpiderDirection")
    os.system("scrapy crawl YourSpiderName")
    os.system("scrapy crawl YourSpiderName -s JOBDIR=Remain/001") # 提高改进
~~~
Scrapy数据抽取写法:
~~~
    //*[@class="title"]//text() 提取class=title标签下的所有文本
    ./div[id="mainn"]  即xpath提取了一个xpath路径，然后继续往下提取文本，拼接xpath时使用，一般没必要.
    //a/@href 提取所有a标签的href属性
    item['domain_id'] = response.xpath('//input[@id="sid"]/@value').get()
    item['name'] = response.xpath('//div[@id="name"]').get()
    item['description'] = response.xpath('//div[@id="description"]').get()
    contain=''.join(contain).strip() #list变成str
    response.content.decode('utf-8');response.encoding;(一个是手动解码,一个是自动解码)
    dic1={"name":"youran","num":"170423"};dict2=dict(name="youran",num="170423").字典的两种创建方式.
~~~
数据持久化部分:
~~~
    with open("allowed_domains.txt", 'a+',encoding='utf-8') as f:
        f.write(m_str)  
    r = requests.get(url)
    with open("file.zip","wb") as f:
        f.write(r.content)

    #jsonVersion1.0
    from scrapy.exporters import JsonLinesItemExporter
    class QidianPipeline(object):
        def __init__(self):
            self.fp=open('qidian.json','wb')
            self.exporter=JsonLinesItemExporter(self.fp,ensure_ascii=False,encoding='utf-8')
        def process_item(self, item, spider):
            self.exporter.export_item(item)
            return item  #这里要注意最好是return item，因为如果pipelines中写了几个，必须返回给其他pipeline使用
        def close_spider(self,spider):
            self.fp.close()

    #jsonVersion2.0(官方示例写法)
    import json
    class QidianPipeline(object):
        def __init__(self):
            self.fp=open('qidian.json','w',encoding='utf-8')
        def process_item(self, item, spider):
            line = json.dumps(item,ensure_ascii=False) + "\n"
            self.fp.write(line)
            return item
        def close_spider(self,spider):
            self.fp.close()  

    #保存为txt
    class TextPipeline(object):
        def __init__(self):
            pass
        def process_item(self, item, spider):
            with open("a.txt","a",encoding="utf-8") as f:
                title=item['title']
                contain=item['contain']
                f.write(title+'\n'+contain+'\n')
            return item
~~~
About items.py: 这部分可以自己写,items本质就是字典,写个字典将数据传给pipeline处理也是一样的.   
举例：name = scrapy.Field()
~~~
About settings.py 
    ROBOTSTXT_OBEY = False #不遵守爬虫协议，改False，默认True
    # 默认注释, 取消之, 并增加user-agent:
    DEFAULT_REQUEST_HEADERS = {
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'en',
    'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36',
    }

    ITEM_PIPELINES = {
    'qidian.pipelines.TextPipeline': 300,#开启这一项，yield item 数据才会进入pipelines，需要pipeline处理数据就开启，
    'qidian.pipelines.JsonPipeline': 400,#数字越小越先执行,如果这里开了多个pipelines，那么pipelines文件中必须也含有这些所有的
    }
    DOWNLOAD_DELAY = 2 #下载延时, 支持浮点数据.
    DOWNLOAD_TIMEOUT = 15  # 下载超时
    RETRY_ENABLED = True # 尝试次数
    RETRY_TIMES = 3
    DEPTH_LIMIT= 3 # 设置爬取深度
~~~

进阶部分:
    为了避免爬取过程异常退出而导致重新爬取采取如下措施:项目目录下要有Remain文件夹.命令:scrapy crawl  <爬虫名>  -s JOBDIR=Remain/001;继续运行:scrapy crawl <爬虫名>  -s JOBDIR=remain/001 .备注:需要重新爬取就换个文件如002就行了.<os.system("scrapy crawl myspider -s JOBDIR=Remain/001")>.  
    Scrapy爬虫以项目目录为基准目录.即scrapy startproject ScrpyDirection,所以相对路径也是基于该目录.  
    allowed_domains = ['www.baidu.com'] #允许域影响yield则注释掉,这个对全站爬虫Rules部分有影响,建议注释掉.  
    yield scrapy.Request(next_url,callback=self.parse,dont_filter=True)#普通爬虫才用这个把下个爬取链接给调度器,dont_filter=True如果缺少将不会跟进爬取，就是只爬一次，不继续往下爬.  
    yield item #item必须是字典  
    pipelines这个组件数据持久化貌似是数据全部爬取完毕再一次性写入,这个问题很大.应该一边爬取一边写入才合理.  
    item=QidianItem(book_name=book_name,book_intro=book_intro).使用items.py.  
    start_urls:全站爬虫可以指定多个初始url.  
 

其他代码:

如果不存在该文件夹则创建
~~~
import os 
main_path="./Image" 
if  not os.path.exists(main_path):
    os.makedirs(main_path)
~~~
全站爬虫rules部分解析
~~~
rules = (
        Rule(LinkExtractor(allow="<正则表达式,当然,还可以写deny(禁止)的规则>"),follow=True),
        Rule(LinkExtractor(allow=".+book\.qidian\.com/info/\d*"), callback='parse_detail', follow=False),
        #follow=True是指如果页面含有符合allow正则的链接就继续提取到调度器
        #callback=parse_item,系统默认的.警告:parse_item这个方法不能复写,这是因为scrapy框架决定,建议注释掉或删掉(最好放着别管).
    )
~~~
利用PIL库下载图片,更漂亮的写法.
~~~
 def down_image_b(self,url):
        import requests
        from PIL import Image
        from io import BytesIO
        main_path="./image"
        if  not os.path.exists(main_path):
            os.makedirs(main_path)
        response = requests.get(url)
        image = Image.open(BytesIO(response.content))
        image.save('./image/f.jpg')
~~~
