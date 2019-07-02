# -*- coding: UTF-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf8')

##use decoder method
def athtml(content,tag,cssclass=None,idname=None):
	addcontent = ""
	if cssclass:
		addcontent += " " + "class=\"%s\""%cssclass
	if idname:
		addcontent += " " + "id=\"%s\""%idname
	return "<%s%s>%s</%s>"%(tag,addcontent,unicode(content),tag)# use unicode to 显示中文，必须重载sys set utf-8

class table_html(object):
	tabidx = 0
	def __init__(self,listhead,table_title=""):
		#self.head = """<table frame="hsides" border="1" cellpadding="2" align="left" cellspacing="0">\n"""+"""<caption align="top">%s</caption>"""%table_title
		table_html.tabidx += 1
		self.head = """<table class="table table-hover">"""+"""%s"""%table_title
		self.end = """</table>"""
		self.button = ''
		self.listhead = listhead[:]
		self.length = len(self.listhead)
		self.content= []
		self.title  = table_title
		strcontent = ""
		for i in xrange(self.length):
			strcontent += athtml(listhead[i],"th") ## 最后加入注解，格式说明：用百分号开头 ##：title ，# 表头，% 表头说明 
		strcontent = athtml(strcontent,"tr")
		strcontent = athtml(strcontent,"thead")	
		self.content.append(strcontent)
	
	def add_row(self,content, number = 1):# rowspan 参数number取消
		assert len(content) == self.length
		strcontent = ""
		for i in xrange(self.length):
			strcontent += athtml(content[i],"td")
		strcontent = athtml(strcontent,"tr")
		strcontent = athtml(strcontent,"tbody")
		self.content.append(strcontent)
	
	def add_noprerow(self,content):
		assert len(content) == self.length
		strcontent = ""
		for i in xrange(self.length):
			strcontent += athtml(content[i],"td")
		strcontent = athtml(strcontent,"tr")
		strcontent = athtml(strcontent,"tbody")
		self.content.append(strcontent)
	def __str__(self):
		self.content = athtml("\n".join([athtml(self.title,"caption"), ]+self.content),"table","table table-hover")
		return self.content

def return_top():
	top_str = u"""<div style="display: block;" id="goTopBtn">
	<a class="backtotop" title="To Top"><span class="glyphicon glyphicon-star"></span></a>
	</div>
	"""
	return top_str
class simple_main(object):
	def __init__(self,title=u"华诺生物信息报告",css="dist"):
		#start = """<html><body><h1>KEGG Pathway Enrichment Analysis</h1><hr />"""
		self.start = """<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta name="description" content="template">
		<meta name="author" content="honortech.cn">
		
		<link rel="icon" href="%s/images/logo.ico">
		<title>%s</title>
		<link href="%s/css/bootstrap.min.css" rel="stylesheet">
		<link href="%s/css/docs.min.css" rel="stylesheet">
		<link href="%s/css/cdocs.css" rel="stylesheet">
		<link href="%s/fancybox/jquery.fancybox-1.3.4.css" rel="stylesheet">
		<link href="%s/css/main.css" rel="stylesheet">
	</head>
<body>
"""%(css,title,css,css, css, css,css) ###also can add 
		self.end = """
</div>
</body>
<script src="%s/js/jquery.min.js"></script>
<script src="%s/js/bootstrap.min.js"></script>
<script src="%s/js/docs.min.js"></script>
<script type="text/javascript" src="%s/fancybox/jquery.mousewheel-3.0.4.pack.js"></script>
<script type="text/javascript" src="%s/fancybox/jquery.fancybox-1.3.4.pack.js"></script>
<script type="text/javascript" src="%s/js/jquery.albumSlider.min.js"></script>
<script type="text/javascript" src="%s/js/new.js"></script>
<script type="text/x-mathjax-config">
	MathJax.Hub.Config({
		displayAlign: "center",
		displayIndent: "0em",
		"HTML-CSS": { scale: 100,
		linebreaks: { automatic: "false" },
		webFont: "TeX"
		},
		SVG: {scale: 100,
		linebreaks: { automatic: "false" },
		font: "TeX"},
		NativeMML: {scale: 100},
		TeX: { equationNumbers: {autoNumber: "AMS"},
		MultLineWidth: "85%%",
		TagSide: "right",
		TagIndent: ".8em"
		}
		});
</script>
<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML"></script>
</html>
"""%(css,css,css,css,css,css,css)

		self.content = ""
		self.cato = ""
		self.title = title
		self.heads = []
		self.id = 1
		self.example_id = 0
		self.headcolors = {1:"#6600CC",
				2:"#6600CC",
				3:"green",
				4:"#996600",
				5:"#996600",
				6:"#996600",
				}

	def add_head_color(self, content,  headlevel=2):
		tag = "h%d"%headlevel
		if headlevel >=4:
			self.content += athtml(content,tag)
			self.id += 1
		if 1 < headlevel < 4: # use 2 and 3 , no 1 
			self.content += athtml(content,tag,cssclass="page-header",idname=str(self.id))
			self.heads.append([content,self.id,headlevel])
			self.id += 1
	def add_head(self,content,headlevel=2):
		self.add_head_color(content,headlevel)

	def add_href(self, content, hrefname):
		self.content += """<a href='%s'>%s</a>"""%(content, hrefname)

	def add_image_title(self, content):
		self.content += """<div align="center"><p>%s</p></div>"""%(content)

	def add_image(self, content, width=75, height=75, svg=1):
		if svg or len(content) <=1:
			self.content += """<div align="center"><img src='%s' width = "%d%%" height="%d%%" /><a href='%s'>高清SVG图</a></div>"""%(content, width, height, content.rsplit(".",1)[0]+".svg")
		elif len(content) >=1 :
			self.content += """<div align="center"><img src='%s' width = "%d%%" height="%d%%" /></div>"""%(content, width, height)
	def add_image_note(self,listcontent,digit=0,cssclass="list-unstyled"):
		content = ""
		for i in xrange(len(listcontent)):
			content += athtml(listcontent[i],"li")
			if digit:
				content = athtml(content,"ol",cssclass=cssclass)
			else:
				content = athtml(content,"ul",cssclass=cssclass)
		self.content += """<div align="center">"""+content+"""</div>"""


	def add_content(self,content):
		self.content += "<p>"+content+"</p>\n"
	
	def add_content_retract(self, content, level = 1, dis=0.2):
		self.content += "<p>&nbsp&nbsp"+content+"</p>\n"
	
	def add_locate(self, content, loc = 'center'):
		self.content += """<div align=%s>%s</div>"""%(loc, content)
	
	def add_button(self, content, cssclass="glyphicon glyphicon-align-left"):
		self.button =  athtml(athtml(content,"span",cssclass=cssclass),"button",cssclass="btn btn-default")
		#self.button = """<button type='button' style='background:%s'><font color='%s'><span style='font-weight:bold;'>%s</span></font></button>"""%(bgcolor, fontcolor, content)	
		return(self.button)# 用于查看


	def add_reference(self, content, size=3, flag=0, dis=0.2):
		if flag==0:
			self.content += """&nbsp&nbsp<font size='%dpx' face='Times'>%s</font><br />"""%(size, content)
		else:
			self.content += """&nbsp&nbsp<font size='%dpx' face='Times'>%s</font><p style="line-height:%fem"><br/></p>"""%(size, content, dis)
		
	def add_precontent(self,content):
		self.content += "<p><pre>"+content+"</pre></p>\n"
	
	def add_line(self):
		self.content += "<hr />\n"
	
	def add_back1(self,content="返回上一页"):
		self.content += """<input type="button" name="Submit" onclick="javascript:history.back(-1);" value="返回上一页">\n"""
		#self.content += """<a href="<a href="javascript :history.back(-1)">返回上一页</a>\n"""
	
	def add_enter(self):
		self.content += "<br />\n"
	
	def add_line_enter(self):
		self.content += "<hr /><br />\n"
	
	def add_li(self,listcontent,digit=0,cssclass=None):
		content = ""
		for i in xrange(len(listcontent)):
			content += athtml(listcontent[i],"li")
		if digit:
			content = athtml(content,"ol",cssclass=cssclass)
		else:
			content = athtml(content,"ul",cssclass=cssclass)
		# athtml(content,tag,cssclass=None,idname=None):
		self.content += content 

	def add_table_header(self,listcontent,tableidx,cssclass=None): ### use three '###' ,,cssclass="dl-horizontal"
		temp = ""
		if listcontent:
			content = """<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#T%d">表格说明</button>
			<div class="modal fade" id="T%d" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
			  <div class="modal-dialog" role="document">
			    <div class="modal-content">
				   <div class="modal-header">
				 	  <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
						 <h4 class="modal-title" id="myModalLabel">表格说明</h4>
					</div>
					<div class="modal-body">
						%s
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
					</div>
				  </div>
			   </div>
			</div>
			"""
			for i in xrange(len(listcontent)):
				temp += athtml(listcontent[i][0],"dt")
				temp += athtml(listcontent[i][1],"dd")
			temp2 = athtml(temp,"dl",cssclass=cssclass)
			self.content += content%(tableidx,tableidx,temp2)
	def add_imgs(self,imgprefixs,suffix,descriptlist):
		content = ""
		numbers = len(imgprefixs) 
		assert numbers == len(descriptlist)
		
		template = """<p class="center">
		<div class="albumSlider">
			<div class="fullview"><img src="%s" /></div>
			<div class="slider">
				<div class="button movebackward" title="向上滚动"></div>
					<div class="imglistwrap">
						<ul class="imglist">
						%s
						</ul>
					</div>
				<div class="button moveforward" title="向下滚动"></div>
			</div>
		</div>
		</p>
		"""
		
		for i in xrange(numbers):
			content += athtml("""<a id="example" href="%s" title="%s" ><img src="%s" /></a><p align="center">%s</p>"""%(imgprefixs[i]+suffix,descriptlist[i],imgprefixs[i]+suffix,descriptlist[i]),"li")
		self.content += template % (imgprefixs[0]+suffix,content)

	def __makecato(self):
		topnav = """<div class="main-wrapper">
<nav class="navbar navbar-default  u-navbar" role="navigation">
	<div class="container-fluid">
		<div class="navbar-header">
			<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-              controls="navbar">
				<span class="sr-only">Toggle navigation</span>
				<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="http://www.honortech.cn" id="backtotop">华诺科技 HonorTech--%s</a>
		</div>
		<div id="navbar" class="navbar-collapse collapse">
			<ul class="nav navbar-nav navbar-right">
				<li><a href="#1">回到顶部</a></li>
				<li><a class="dropdown-toggle" id="dropdownMenu1" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">分析条目<span class="caret"></span></a>
					<ul class="dropdown-menu">
						%s
					</ul>
				</li>
			</ul>
		</div>
	</div>
</nav>
</div>
<div class="col-sm-2 col-md-2" role="complementary">
	<nav class="bs-docs-sidebar hidden-print hidden-xs hidden-sm">
		<ul class="nav bs-docs-sidenav">
			<li><a href="#1">回到顶部</a></li>
			%s
		<ul>
	</nav>
</div>
<div class="col-sm-9 col-md-9" role="main">
"""
		content = ""
		content2 = ""
		flag = 0
		if len(self.heads) >= 1:
			for tmphead,tmpid,headlevel in self.heads:
				content2 += """<li><a href="#%d">%s</a></li>\n"""%(tmpid,tmphead)
				if headlevel == 2:
					if flag == 1:
						content +="""</ul></li>\n"""
						flag = 0
					else:content +="""</li>\n"""
					content += """<li><a href="#%d">%s</a>\n"""%(tmpid,tmphead)
				elif headlevel == 3 and flag == 0:
					content += """<ul class="nav"><li><a href="#%d">%s</a></li>\n"""%(tmpid,tmphead)
					flag = 1
				elif headlevel == 3 and flag == 1:
					content += """<li><a href="#%d">%s</a></li>\n"""%(tmpid,tmphead)
			if flag == 1: content +="""</ul></li>\n"""
			else:content +="""</li>\n"""
			self.cato = topnav%(self.title,content2,content)
		return 0

	def __str__(self):
		if self.content == "":
			sys.stderr.write("[ERROR] html page has no content!\n")
			return None
		self.__makecato()
		return "\n".join([self.start,self.cato,self.content,self.end])
	
def get_sampleinfo(sampleinfo, number = 1):
	f = file(sampleinfo,"r")
	header = ["#","Samplename","Filename","SN","Category","Category name"]
	for line in f:
		if line.startswith("##"):continue
		if line.startswith("#"):
			header = ["#",] + line.rstrip("\n")[1:].split("\t")
			break
	f.seek(0)
	table = table_html(header,"Table: sample information list")
	idx = 1
	samplename = []
	files = []
	for line in f:
		if line.startswith("##"):continue
		if line.startswith("#"):
			header = ["#",] + line.rstrip("\n")[1:].split("\t")
			continue
		arr = line.rstrip("\n").split()
		sn = arr[0]
		files.append(arr[1].split(","))
		table.add_row([str(idx),"""<a id="%s_x" href="#%s">%s</a>"""%(sn,sn,sn)] + arr[1:], number = number)
		idx += 1
		samplename.append(sn)
	return str(table),samplename,files

def xls2table(fxls,title=None,header=None, rowNumber = 10, merge_number = 1):
	f = file(fxls,"r")
	if header == None:
		header = "";
	if not title:
		title = "";
	rowNumber = int(rowNumber)
	descripts = []
	for index, line in enumerate(f):
		if line.startswith("###"):
			tmpabbr,tmpdes= line.rstrip().split("###")[1].lstrip("#").split(":",1)
			descripts.append([tmpabbr,tmpdes])
			continue
		elif line.startswith("##"):
			title = "Table: "+line[2:].rstrip()
			continue
		elif line.startswith("#"):
			header = line.rstrip("\n").split("\t")
		else:break
	f.seek(0)
	if rowNumber < 20: title += "（显示前%d行）"%rowNumber
	table = table_html(header,table_title=title)
	note = ""; count = 0; flag = 1
	while 1:
		line = f.readline()
		if not line: break
		if line.startswith("#"):continue
		if line.startswith("Note:"):
			#xnote = line+f.read()
			break
		
		table.add_row(line.rstrip("\n").split("\t"), number = merge_number)
		if count >= rowNumber - 1: 
			flag = 1
			break
		count += 1
	f.close()
	
	return str(table)+"""<strong><a href="%s">点击查看详表</a></strong>\n"""%fxls,descripts,table.tabidx

if __name__  == "__main__":
	#print get_sampleinfo(sys.argv[1])
	import sys
	import mhtml_v4
	html_main = mhtml_v4.simple_main(title="链特异性文库-RNAseq分析结果") ## 添加分析title
	#html_main.add_honor_title(title="链特异性文库-RNAseq生物信息分析结果")
	html_main.add_head_color("1. 分析基本流程", headlevel = 2)
	html_main.add_content_retract(""">>> step 1. 下机数据质量控制，评估测序数据的可靠性""")
	html_main.add_line();html_main.add_enter()

	html_main.add_head_color("2. 项目实验设计",headlevel = 2)
	html_main.add_content_retract(""">>> step 1. 下机数据质量控制，评估测序数据的可靠性""")
	tablecontent,descripts,tableidx = mhtml_v4.xls2table(sys.argv[1]) # 添加表格
	html_main.add_precontent(tablecontent)                   # 调用函数1, 添加表格里的内容，默认只显示前10行
	html_main.add_table_header(descripts,tableidx)           # 调用函数2, 用于添加表头的说明，表头说明在excel里的写法，参见sampleinfo.xls, 注意### 开头及冒号, 写在title和表头之间
	html_main.add_line();html_main.add_enter()



	html_main.add_head_color("3. 基本分析结果",headlevel = 2)
	html_main.add_li(["SN1 是1号样本","SN2 是2号样本","SN3 是3号样本"])           # 添加 li  
	html_main.add_li(["SN1 是1号样本","SN2 是2号样本","SN3 是3号样本"],digit=1)   # 添加 li， 带数字 
	html_main.add_line();html_main.add_enter()



	statdir = "1.QC/"
	html_main.add_head_color("转录本重构",headlevel = 3)
	html_main.add_image(statdir+"S0.s_0h_2.clean.fq.gz.png",svg=1) # 添加单个图片,带SVG图,svg=1 (默认选项)，若无，则 svg=0
	html_main.add_line(); html_main.add_enter()
	
	
	# 添加图片集合比较麻烦，需要图片的前缀，后缀，以及我们想显示每个图片的名字，一般而言，我们分样本时，前缀都是sn号，这里我举了不一致的情况。
	imgprefixs = [statdir+"S0.s_0h_1",statdir+"S12.s_12h_1"]
	suffix = ".clean.fq.gz.png"
	sns    = ["S0","S12"]
	html_main.add_head_color("转录本定量",headlevel = 3)
	html_main.add_content_retract(""">>> step 1. 下机数据质量控制，评估测序数据的可靠性""") # 添加图片集合比较
	html_main.add_imgs(imgprefixs,suffix,sns)
	html_main.add_line(); html_main.add_enter()

	html_main.add_head_color("差异表达分析",headlevel = 3)
	html_main.add_content_retract(""">>> step 1. 下机数据质量控制，评估测序数据的可靠性""")
	html_main.add_content_retract(""">>> step 1. 下机数据质量控制，评估测序数据的可靠性""")
	html_main.add_line(); html_main.add_enter()

	html_main.add_head_color("4. 附录", headlevel = 2)
	html_main.add_head_color("基因组及注释文件", headlevel = 3)
	html_main.add_content_retract(""">>> step 1. 下机数据质量控制，评估测序数据的可靠性""")
	html_main.add_head_color("基因组及注释文件", headlevel = 3);html_main.add_content_retract(""">>> st""")
	html_main.add_head_color("基因组及注释文件", headlevel = 3);html_main.add_content_retract(""">>> st""")
	with open('ncRNA_mRNA_analysis_v4.html', 'w') as fp:
		fp.write(str(html_main))
	
