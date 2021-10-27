---
title: "java爬虫笔记"
date: 2021-10-27T12:19:59+08:00
draft: false
---

# 前言
这还是19年的时候，搞java爬虫时候，当时弄完后整理好的一些笔记，后面又删除了一些简单的内容。笔记的话主要是分为两块，爬虫一个是使用HttpClient+Jsoup完成，另外一个是selenium爬虫。稍微提一下selenium吧，事实上这个东西不是爬虫，是自动化测试工具，但是它做爬虫可以简化很多麻烦的事情，因为selenium本质就是模拟人类操作。


# Selenium3部分:
```
配置部分:System.setProperty("webdriver.chrome.driver", "C:/Program Files (x86)/Google/Chrome/Application/chromedriver.exe");ChromeOptions options = new ChromeOptions();

设置禁止加载项,2就是代表禁止加载的意思:Map<String, Object> prefs = new HashMap<String, Object>();prefs.put("profile.managed_default_content_settings.javascript", 2);prefs.put("profile.managed_default_content_settings.images", 2);    

options.setExperimentalOption("prefs", prefs);options.setHeadless(Boolean.TRUE);无头模式.
	
启动driver并将设定的参数配置好:WebDriver driver = new ChromeDriver(options);driver.manage().window().maximize();
隐式等待设置一次即可，即等待页面元素出现的最大时间:driver.manage().timeouts().implicitlyWait(60, TimeUnit.SECONDS);Thread.sleep(3000);线程中断.
options.addArguments("--user-data-dir=C:/Users/Administrator/AppData/Local/Google/Chrome/User Data/Default");通过配置参数禁止data;的出现，实际路径通过chrome version查看然后修改下.

页面元素不存在的问题，使用try catch执行，立一个Boolean flag，根据flag是否修改，来决定元素是否存在，再进行处理.
```
# HttpClient+Jsoup部分:
```
CloseableHttpClient httpClient=HttpClients.createDefault();// 创建httpclient请求对象
String url="https://www.mafengwo.cn/traveller/";
HttpGet httpGet=new HttpGet(url);// 声明httpget请求对象 
//请求参数配置
RequestConfig config=RequestConfig.custom().setConnectTimeout(1000)
					.setConnectionRequestTimeout(500)
					.setSocketTimeout(10*1000)
					.build();
httpGet.setConfig(config); //参数放到httpGet里面
httpGet.addHeader("User-Agent", "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.6)");
httpGet.addHeader("Content-Type", "application/x-www-form-urlencoded");
CloseableHttpResponse response = httpClient.execute(httpGet); // 使用httpclient发起请求
String html =EntityUtils.toString(response.getEntity(), "utf-8");//获取请求内容，设置编码.
response.close();   httpClient.close();  //注意关闭资源

httpclient结束,下面是jsoup部分
Document doc=Jsoup.parse(html);//jsoup将获取的html放到doc中分析
String title=doc.getElementsByTag("title").text();//举例分析，处理页面
```

# 下载图片代码:
```
	private static void downloadPicture(String targetUrl,String path) {
        URL url = null;
        try {
            url = new URL(targetUrl);
            DataInputStream dataInputStream = new DataInputStream(url.openStream());

            FileOutputStream fileOutputStream = new FileOutputStream(new File(path));
            ByteArrayOutputStream output = new ByteArrayOutputStream();

            byte[] buffer = new byte[1024];
            int length;

            while ((length = dataInputStream.read(buffer)) > 0) {
                output.write(buffer, 0, length);
            }
            BASE64Encoder encoder = new BASE64Encoder();
            String encode = encoder.encode(buffer);//返回Base64编码过的字节数组字符串
            fileOutputStream.write(output.toByteArray());
            dataInputStream.close();
            fileOutputStream.close();
        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
```

# 数据库代码:(防sql注入)
```
	private static void DataSolve(Connection conn, TravelArtical myObject) {
			try {
				String title = myObject.getTitle();
				String artical = myObject.getArtical();
				int num=myObject.getNum();
				String sql = "INSERT INTO travel(title,artical，num) VALUES " + " (?,?,?)";
				PreparedStatement pre = (PreparedStatement) conn.prepareStatement(sql);
				pre.setString(1,title);
				pre.setString(2,artical);
				pre.setInt(3,num);
				pre.executeUpdate();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
```

# JDBC Helper代码:
```
	public class DataBaseConnectionHelp {
		private static final String driver = "com.mysql.jdbc.Driver";
		//设置encoding防止出现中文？
		private static final String url = "jdbc:mysql://localhost:3306/kevin?characterEncoding=utf-8";
		//?characterEncoding=utf-8&amp;serverTimezone=UTC&amp;useSSL=false   MySql8.0以上，jdbc接口名也改了
		private static final String username = "root";
		private static final String password = "root";
		
		private static Connection conn=null;
		
		static {
			try {
				Class.forName(driver);
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
			}
		}
		public static Connection getConnection() {
			if(conn==null) {
				try {
					conn = DriverManager.getConnection(url,username,password);
				} catch (SQLException e) {
					e.printStackTrace();
					System.out.println("数据库连接失败");
				}
				return conn;
			}else {
				return conn;
			}	
		}	
	}
```

其他部分:
	String类型转integer 类型，如果str非数字会报错 int num=Integer.parseInt(str);


关于文件流的代码:
```
	package myCode;
	import java.io.BufferedReader;
	import java.io.File;
	import java.io.FileInputStream;
	import java.io.FileNotFoundException;
	import java.io.FileOutputStream;
	import java.io.FileReader;
	import java.io.IOException;
	//https://www.cnblogs.com/chen-lhx/p/5610678.html
	//所有方法都已经单独测试过了，可以直接使用
	public class IOAndFileCode {
		public static void main(String[] args) throws Exception {
			String path="D:/javaTest";
			String str;
			//读文件
			FileInputStreamDemo(path);
			//写文件
			PrintStream(path);
			
			//读文件 在IO操作中，BufferedReader和BufferedWriter效率更高
			str=BufferReaderDemo(path);
			//写文件 在IO操作中，BufferedReader和BufferedWriter效率更高
			BufferedWriterDemo(path,str);
			
			//创建文件
			createFile(path);
			//删除文件
			deleteFile(path);
			//创建目录
			createDir(path);
			//删除目录
			deleteDir(path);
		}
		private static void BufferedWriterDemo(String path, String str) throws IOException {
			File file=new File(path+"/"+"hello.txt");
			if(!file.exists())
				file.createNewFile();
			FileOutputStream out=new FileOutputStream(file,true);
			StringBuffer sb=new StringBuffer();
			sb.append(str);
			out.write(sb.toString().getBytes("utf-8"));
			/*
			* for(int i=0;i<10000;i++){ StringBuffer sb=new StringBuffer();
			* sb.append("这是第"+i+"行:前面介绍的各种方法都不关用,为什么总是奇怪的问题 ");
			* out.write(sb.toString().getBytes("utf-8")); }
			*/  
			out.close();
			
		}
		private static String BufferReaderDemo(String path) throws IOException {
			File file=new File(path+"/"+"01.txt");
			if(!file.exists()||file.isDirectory()) 
				throw new FileNotFoundException();
			BufferedReader br=new BufferedReader(new FileReader(file)); 
			String temp=null;
			StringBuffer sb=new StringBuffer();
			temp=br.readLine();
			while(temp!=null) {
				sb.append(temp+"\n");
				temp=br.readLine();
			}
			return sb.toString();
		}
		//删除目录，删除目录必须保证目录下没有子目录否则删除失败,采用递归地方式删除该目录下所有文件
		private static void deleteDir(String path) {
			File dir=new File(path+"/"+"makeDir");
			if(dir.exists()) {
				File[]temp =dir.listFiles();
				for(int i=0;i<temp.length;i++) {
					if(temp[i].isDirectory()) {
						deleteDir(path+"/"+temp[i].getName());	
					}else {
						temp[i].delete();
					}
				}
				dir.delete();
			}else {
				System.out.println("目录不存在");
			}
			
		}
		//删除文件
		private static void deleteFile(String path) {
			File file =new File(path+"/"+"newFile");
			if(file.exists()&&file.isFile()) {
				file.delete();
			}else {
				System.out.println("文件不存在");
			}
		}
		//创建文件
		private static void createFile(String path) throws IOException {
			// TODO Auto-generated method stub
			File file=new File(path+"/"+"newFile");
			if(!file.exists()) {
				file.createNewFile();
			}else {
				System.out.println("文件已经存在");
			}
		}
		//创建文件夹
		private static void createDir(String path) {
			File dir=new File(path+"/"+"makeDir");
			if(!dir.exists()) {
				dir.mkdir();
			}else {
				System.out.println("目录已存在");
			}
			
		}
		//读取文件
		private static String FileInputStreamDemo(String path) throws IOException {
			File file=new File(path+"/"+"01.txt");
			if(!file.exists()||file.isDirectory()) 
				System.out.println("fileNotFound");
			FileInputStream fis=new FileInputStream(file);
			byte[]buf=new byte[1024];
			StringBuffer sb=new StringBuffer();
			while((fis.read(buf)!=-1)) {
				sb.append(new String(buf));
				buf=new byte[1024];//重新生成，避免和上次读取数据重复
			}
			System.out.println(sb);
			return sb.toString();	
		}
		//写文件(文件不存在则创建)
		private static void PrintStream(String path) {
			try {
				FileOutputStream out=new FileOutputStream(path+"/"+"02.txt");
				java.io.PrintStream p=new java.io.PrintStream(out);
				for(int i=0;i<10;i++) {
					p.println("this is "+i+"line");
				}
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			}
		}
		
	}
```

# 遇到的问题

1. SQL注入问题：在将数据写入数据库的时候一定要注意防SQL注入，因为正好碰到爬取到某条数据插入数据库的时候因为代码直接写的，没有注意SQL注入导致报错，异常。

2. Selenium配置问题：需要注意的是下载对应浏览器版本的驱动（drive），如果是Chrome就下载对应版本的Drive，Firefox就下载Firefox对应的驱动。

3. JDBC问题：准确来说不算是问题，因为完全不了解，所以我在这里搞了半天才弄懂这个代码要怎么写，当然大部分是参考网上的。

4. Mysql版本问题：5.7和8.0版本的JDBC的写法好像有些不一样，这里算是一个坑吧，如果没必要软件还是不要随意升级。

# 心得
其实当然是有很多的了，但是经历过一遍以后，就发现很多细小的地方好像没必要写，每个人的认知不一样，也许我的小问题你觉得完全不是问题。

代码是我整理过好几次后的，所以看起来，审美还能接受吧。HttpClient的配置部分可能是当时第一次弄，反正那个地方我反复折腾了好几次才搞清楚，Selenium配置也差不多慢慢理解吧。Selenium的无头模式建议上手后再开启，刚开始还是看有头模式吧，比较清楚，一般调试时候出问题，我也会打开有头模式看什么情况。

关于jar包部分，Maven是真的挺好用的，需要什么jar包，直接搜索名字 + Maven，不用自己手动去下，那样太影响开发效率了。