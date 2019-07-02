# -*- coding: utf-8 -*-
import re
import urllib,urllib2

#urllib:
#urllib2: The urllib2 module defines functions and classes which help in opening
#URLs (mostly HTTP) in a complex world — basic and digest authentication,
#redirections, cookies and more.

def translate(text):
	'''模拟浏览器的行为，向Google Translate的主页发送数据，然后抓取翻译结果 '''
	#text 输入要翻译的英文句子
	text_1=text
	#'langpair':'en'|'zh-CN'从英语到简体中文
	values={'hl':'zh-CN','ie':'UTF-8','text':text_1,'langpair':"'en'|'zh-CN'"}
	url='https://translate.google.cn'
	data = urllib.urlencode(values)
	req = urllib2.Request(url,data)
	#模拟一个浏览器
	browser='Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)'
	req.add_header('User-Agent',browser)
	#向谷歌翻译发送请求
	response = urllib2.urlopen(req)
	#读取返回页面
	html=response.read()
	#从返回页面中过滤出翻译后的文本
	#使用正则表达式匹配
	#翻译后的文本是'TRANSLATED_TEXT='等号后面的内容
	#.*? non-greedy or minimal fashion
	#(?<=...)Matches if the current position in the string is preceded
	#by a match for ... that ends at the current position
	p=re.compile(r"(?<=TRANSLATED_TEXT=).*?;")
	m=p.search(html)
	text_2=m.group(0).strip(';')
	return text_2

if __name__ == "__main__":
	#text_1 原文
	#text_1=open('c:\\text.txt','r').read()
	
	text_1='Hello, my name is Smith. What are you doing now? '
	text_1="""A study of 1,182 young Scottish asthma patients (age, 3-22 years) concluded that rs1042713(A) alleles are significantly associated with "exacerbations" of their condition, regardless of treatment regimens (odds ratio 1.30, CI: 1.09-1.55, p=0.003). This didn't hold true for patients using inhalers less than once per day; and it was particularly true for those receiving daily inhaled long- or short-acting beta(2)-agonist treatment (OR, 1.64, CI: 1.22-2.20, p=.001). This may therefore indicate that regular inhalant use of albuterol (found in Ventolin) or long-acting agonists, such as salmeterol found in Advair, may be counter-productive in young asthma patients carrying one or especially two rs1042713(A) alleles."""
	print('The input text: %s' % text_1)
	text_2=translate(text_1).strip("'")
	print('The output text: %s' % text_2)


