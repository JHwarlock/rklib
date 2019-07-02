#!/usr/bin/env python
# encoding=utf-8
import sys
import time,datetime
import os,sys
import getpass
import hashlib
from optparse import OptionParser,OptionGroup,OptionContainer
import pdb
from Crypto.pct_warnings import PowmInsecureWarning
import warnings
#import paramiko
from email import encoders
from email.header import Header
from email.mime.text import MIMEText
from email.utils import parseaddr, formataddr
from email.MIMEMultipart import MIMEMultipart
from email.MIMEBase import MIMEBase
import smtplib

sys.path.append("/home/rongzhengqin/Cython/git/private")
from emailinfo import *
#print testmsg
#print project_mail
#print passwd


def _format_addr(s):
	name, addr = parseaddr(s)
	return formataddr(( \
			Header(name, 'utf-8').encode(), \
			addr.encode('utf-8') if isinstance(addr, unicode) else addr))
def _combine_addr(name,addr):
	return "%s<%s>"%(name,addr)

class Emailaddr(object):
	def __init__(self,name,addr):
		self.name = name
		self.addr = addr
		self.cb = _combine_addr(name,addr)
		self.fc = _format_addr(self.cb)

class Emailserver(object):
	def __init__(self,from_addr="master",to_addr=["rongzhengqin","h3351689f"],cc=["service",],project_mail=project_mail):
		self.login_user= project_mail[from_addr]

		self.from_addr = Emailaddr(from_addr,project_mail[from_addr])
		self.passwd    = passwd
		
		self.to_addr   = []
		for name in to_addr:
			self.to_addr.append(Emailaddr(name,project_mail[name]))
		self.cc        = []
		for name in cc:
			self.cc.append(Emailaddr(name,project_mail[name]))
		
		self.smtp_server    = "smtp.163.com"
	def msg_send(self,subject=u'Basepedia项目提交',msgcontent = testmsg,attachment = "/home/michael/bin/ftp_client/FTP_USER_manual.rar",filename="FTP_USER_manual.rar"):
		msg = MIMEMultipart()
		mail = msg.attach(MIMEText(msgcontent,"html","utf-8"))
		msg['From'] = self.from_addr.fc
		
		msg['To']   = ",".join(map(lambda i: i.fc,self.to_addr))
		msg['CC']   = ",".join(map(lambda i: i.fc,self.cc))     ##self.cc.fc
		msg['Subject'] = Header(subject, 'utf-8').encode()
		toaddrs = map(lambda i: i.addr,self.to_addr)  + map(lambda i: i.addr,self.cc)
		if attachment is not None:
			with open(attachment, 'rb') as f:
				# 设置附件的MIME和文件名，这里是rar类型: .MIMEBase（_maintype，_subtype，*，policy = compat32，** _ params ）：_maintpe是Content-Type主要类型（text or image），_subtype是Content-Type次要类型（plain or gif），_params是一个键值字典参数直接传递给Message.add_header
				# https://wiki.basepedia.com/doku.php?id=公共:tech:mime_类型列表
				mime = MIMEBase('application', 'octet-stream', filename=filename)
				# 加上必要的头信息:
				mime.add_header('Content-Disposition', 'attachment', filename=filename)
				mime.add_header('Content-ID', '<0>')
				mime.add_header('X-Attachment-Id', '0')
				# 把附件的内容读进来:
				mime.set_payload(f.read())
				# 用Base64编码:
				encoders.encode_base64(mime)
				# 添加到MIMEMultipart:
				msg.attach(mime)
		# smtpPort = '25' ,  sslPort  = '587'
		server = smtplib.SMTP_SSL(self.smtp_server, 587, timeout=3)
		server.ehlo()
		#server.starttls()  #encrypt email
		server.set_debuglevel(1)
		server.login(self.login_user, self.passwd)
		server.sendmail(self.from_addr.addr, toaddrs, msg.as_string())
		server.quit()
		return 0

if __name__ == "__main__":
	ins_email = Emailserver()
	ins_email.msg_send()

"""
try:
	#连接smtp服务器，明文/SSL/TLS三种方式，根据你使用的SMTP支持情况选择一种
	#普通方式，通信过程不加密
	smtp = smtplib.SMTP(smtpHost,smtpPort)
	smtp.ehlo()
	smtp.login(username,password)
	
	#tls加密方式，通信过程加密，邮件数据安全，使用正常的smtp端
	#smtp = smtplib.SMTP(smtpHost,smtpPort)
	#smtp.set_debuglevel(True)
	#smtp.ehlo()
	#smtp.starttls()
	#smtp.ehlo()
	#smtp.login(username,password)
	
	#纯粹的ssl加密方式，通信过程加密，邮件数据安全
	#smtp = smtplib.SMTP_SSL(smtpHost,sslPort)
	#smtp.ehlo()
	#smtp.login(username,password)
	
	#发送邮件
	smtp.sendmail(fromMail,toMail,mail.as_string())
	smtp.close()
	print 'OK'
except Exception as e:
	    print e
"""

