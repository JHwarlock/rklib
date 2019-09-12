# -*- coding: UTF-8 -*-
import sys
import Image
import ImageDraw
import os
##plot_list is :
##geneid  mark(>0 red  or <0 blue  or = 0: yellow)
def __parse_kegg_db(db_list):
	db = open(db_list,"r")
	h = {}#keggid -> geneORcompoundORdurgORothers -> [[],]
	hname = {}#geneORcompoundORdurg... -> [keggid,]
	for line in db:
		keggid,name,other = line.rstrip("\n").split("\t",2)
		if keggid in h:
			if name in h[keggid]:
				h[keggid][name].append(other)
			else:
				h[keggid][name] = [other,]
		else:
			h[keggid] = {}
			h[keggid][name] = [other,]
		if name in hname:
			hname[name].append(keggid)
		else:
			hname[name] = [keggid,]
	#for keggid in h:
	#	for name in h[keggid]:
	#		print(keggid+"\t"+name+"\t"+str(h[keggid][name]))
	db.close()
	return h,hname

def __parse_plot_list(plot_list):
	f = open(plot_list,"r")
	harr = {}
	for line in f:
		if line.startswith("#"):continue
		name,comment,types = line.rstrip("\n").split("\t",2)
		if name in harr:
			harr[name].append([comment,types])
		else:
			harr[name] = [[comment,types],]
	f.close()
	return harr

class map_html(object):
	def __init__(self,keggid,outhtmlname):
		self.head = """<html>\n<img src="%s.mark.png" usemap="#mapdata" border="0" />\n<map name="mapdata">"""%keggid
		self.elements = []
		self.style = """<area shape=%s\tcoords=%s\thref="http://www.kegg.jp/%s"\ttitle="%s" />"""
		self.end = """</map>\n</img>\n</html>"""
		self.outhtml = outhtmlname
	def add_element(self,info):
		#info = ("rect","547,113,593,130","/dbget-bin/www_bget?hsa:85365","85365 (ALG2)")
		#<area shape=rect        coords=547,113,593,130  href="/dbget-bin/www_bget?hsa:85365"    title="85365 (ALG2)\nXXX\nXXXX" />
		self.elements.append(self.style%info)
	def finish(self):
		fout = open(self.outhtml,"w")
		fout.write("\n".join([self.head,"\n".join(self.elements),self.end]))
		fout.close()
		return 0

class table_html(object):
	def __init__(self,listhead):
		self.head = """<table frame="hsides" border="1" cellpadding="2" align="center" cellspacing="0">"""
		self.end = """</table>"""
		self.h_head = """<tr>""" 
		self.h_end = """</tr>"""
		self.v_head = """<td>"""
		self.v_end = """</td>"""
		self.listhead = listhead[:]
		self.length = len(self.listhead)
		self.content = []
		##add_table listhead
		strcontent = "<tr>\n"
		for i in range(self.length):
			strcontent += "<th>"+str(listhead[i])+"</th>\n"
		strcontent += "</tr>"
		self.content.append(strcontent)
	def add_row(self,content):
		assert len(content) == self.length
		strcontent = "<tr>\n"
		for i in range(self.length):
			strcontent += "<td>"+str(content[i])+"</td>\n"
		strcontent += "</tr>"
		self.content.append(strcontent)
	def __str__(self):
		return "\n".join([self.head,"\n".join(self.content),self.end])
		

class image_plot(object):
	def __init__(self,inputfig,outputfig):
		self.inputfig = Image.open(inputfig)
		self.draw = ImageDraw.Draw(self.inputfig)
		self.outputfig = outputfig
	def drawplot(self,plotinfo):
		shape,coor,color = plotinfo
		## three kinds: poly, rect, circle
		if shape == "rect":
			tmp1 = map(int,coor.split(","))
			tmp2 = [tmp1[0],tmp1[1]-1,tmp1[2],tmp1[3]+1]
			self.draw.rectangle(tmp1,outline=color)
			self.draw.rectangle(tmp2,outline=color)
		elif shape == "poly":
			tmp = map(int,coor.split(","))
			tmp1 = [(tmp[0]+tmp[6])/2,(tmp[1]+tmp[7])/2,(tmp[2]+tmp[4])/2,(tmp[3]+tmp[5])/2]
			tmp2 = [tmp1[0]+1,tmp1[1]+1,tmp1[2]+1,tmp1[3]+1]
			self.draw.line(tmp1,color,width = 2)
			#self.draw.rectangle(tmp2,outline=color)
		elif shape == "circle":
			## to plot C
			pass
		else:
			sys.stderr.write("[Warning] Unkown shape: %s"%shape)
			pass
	def drawmark(self,plotinfo):
		shape,coor,color = plotinfo
		##define marker's coor ellipse
		##use outframe to define and plot with rad
		tmp = map(int,coor.split(","))
		if shape == "rect":
			#tmp1 = [tmp[0]+2,(tmp[1]+tmp[3])/2+5,tmp[0]+8,(tmp[1]+tmp[3])/2-5]
			centerx = tmp[0]+4
			centery = (tmp[1]+tmp[3])/2
			radx = 10
			rady = 10
			tmp1 = [centerx - radx/2,centery - rady/2,centerx+radx/2,centery+rady/2]
			self.draw.ellipse(tmp1,outline = color)
		elif shape == 'poly':
			centerx = ((tmp[0]+tmp[6])/2+(tmp[2]+tmp[4])/2)/2
			centery = ((tmp[1]+tmp[7])/2+(tmp[3]+tmp[5])/2)/2
			radx = 10
			rady = 10
			tmp1 = [centerx - radx/2,centery - rady/2,centerx+radx/2,centery+rady/2]
			self.draw.ellipse(tmp1,outline = color)
		elif shape == "circle":pass
		else:
			sys.stderr.write("[Warning] Unkown shape: %s"%shape)
			pass
	def close(self):
		self.inputfig.save(self.outputfig)
		return 0

html_start = \
"""
<html>
<body>
<h1>KEGG Pathway Analysis</h1>
<hr />
"""
html_end = \
"""
<hr />
</body>
</html>
"""

from operator import itemgetter, attrgetter
def do_plot_kegg_first_html(hmark,pathway_list):
	f = open(pathway_list,"r")
	content = []
	listhead = ["#KEGGid","Description","Class","SubClass","Numbers"]
	link_style = """<a href="mark_maps/%s.html">%s</a>"""
	for line in f:
		if line.startswith("#"):continue
		keggid,keggdes,tclass,subclass = line.rstrip("\n").split("\t")
		if keggid in hmark:
			content.append([link_style%(keggid,keggid),keggdes,tclass,subclass,hmark[keggid]])
	f.close()
	arr = sorted(content,key=itemgetter(4),reverse=True)
	tables = table_html(listhead)
	for i in range(len(arr)):
		tables.add_row(arr[i])
	str_tables = str(tables)
	fout = open("kegg_analysis.html","w")
	fout.write("\n".join([html_start,str_tables,html_end]))
	fout.close()
	return 0

def plot_kegg(plot_list,db_list,pathway_list,indir_pngs="./",outdir_htmlpngs = "mark_maps",flag_ko=0):
	hmark = {}
	hinfo,hname = __parse_kegg_db(db_list)
	if isinstance(plot_list,dict):
		harr = plot_list
	else:harr = __parse_plot_list(plot_list)
	#identify which keggid to plot
	for name in harr:
		if name in hname:
			keggids = hname[name]
			for keggid in keggids:
				if keggid in hmark:
					hmark[keggid] += 1
				else:hmark[keggid] = 1
	#start to plot, 0 is yellow 1 is red 2 is blue (0,0,255)  0,255,0 is green
	colors = [(160,82,45),(255,0,0),(34,139,34)]
	if flag_ko:
		colors = [(160,82,45),(255,0,0),(34,139,34)]
	for keggid in hmark:
		if not os.path.isdir(outdir_htmlpngs):
			try:os.mkdir(outdir_htmlpngs)
			except:
				sys.stderr.write("Error: %s cannot creat PNG outdir: %s!\n"%("[plot_map]",outdir_htmlpngs))
				sys.exit(1)
		#print(indir_pngs)
		#print(keggid)
		#print(outdir_htmlpngs)
		image_instance = image_plot(indir_pngs+os.path.sep+keggid + ".png",outdir_htmlpngs+os.path.sep+keggid+".mark.png")
		html_instance = map_html(keggid,outdir_htmlpngs+os.path.sep+keggid+".html")
		hcoor = {}
		###需要 按坐标画 ，否则 多次被覆盖 所以format hcoor 
		for name in hinfo[keggid]:
			if name in harr:
				comment_types = harr[name]
				for comment_type in comment_types:
					comment,types = comment_type
					comment = name+" "+comment.strip()
					types = map(int,types.split())
					infos = hinfo[keggid][name]
					for tmp_info in infos:
						shape,coor,href,title = tmp_info.split("\t")
						if coor in hcoor:
							shape,tmptypes,href,tmpcomment,title = hcoor[coor]
							if tmptypes == None:
								hcoor[coor] = [shape,types,href,comment,title]
							else:
								tmpcomment +=(", "+comment)
								for i in range(len(types)):
									if types[i] == -1:types[i] = tmptypes[i]
									elif tmptypes[i] == -1:pass
									else:
										if types[i] != tmptypes[i]:types[i] = 0
								hcoor[coor] = [shape,types,href,tmpcomment,title]
						else:
							hcoor[coor] = [shape,types,href,comment,title]
			else:
				types = None
				comment = None
				infos = hinfo[keggid][name]
				for tmp_info in infos:
					shape,coor,href,title = tmp_info.split("\t")
					if coor not in hcoor:
						hcoor[coor] = [shape,types,href,comment,title]
		for coor in hcoor:
			shape,types,href,comment,title = hcoor[coor]
			if types is not None:
				html_instance.add_element((shape,coor,href,comment+" || "+title))
				if types[0] != -1:
					color = colors[types[0]]
				#print [shape,coor,color]
					image_instance.drawplot([shape,coor,color])
				if types[1] != -1:
					color = colors[types[1]]
					image_instance.drawmark([shape,coor,color])
				#if len(types) == 2:
				#	image_instance.drawmark
			else: html_instance.add_element((shape,coor,href,title))
		html_instance.finish()
		image_instance.close()
	#do_plot_kegg_first_html(hmark,pathway_list)
	return 0

if __name__ == "__main__":
	plot_kegg(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4])
	#__parse_kegg_db(sys.argv[1])
	#plot_list = sys.argv[1]
	#db_list = sys.argv[2]
	#pngs = sys.argv[3:]
