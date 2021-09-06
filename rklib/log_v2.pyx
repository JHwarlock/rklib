#!/usr/bin/env python
# -*- coding: UTF-8 -*-
import sys
import logging
import time
import logging.handlers

class Log(object):
	def __init__(self,fn,name):
		rq = time.strftime('%Y%m%d', time.localtime(time.time()))
		self.filename = fn +"_" +rq + '.log'
		self.name = name
		self.logger = logging.getLogger(self.name)    
		self.logger.setLevel(logging.INFO)    
		self.ch = logging.StreamHandler()
		gs = logging.Formatter('%(asctime)s - %(levelname)s - %(name)s[line:%(lineno)d] - %(message)s')
		self.ch.setFormatter(gs)
		self.fh = logging.handlers.TimedRotatingFileHandler(self.filename, 'D', 1, 10)
		self.formatter = logging.Formatter('%(asctime)s - %(levelname)s -   %(name)s[line:%(lineno)d] - %(message)s')
		self.fh.setFormatter(self.formatter)
		self.logger.addHandler(self.fh)
		self.logger.addHandler(self.ch)
	def getlog(self):
		return self.logger
class CustomError(Exception):
	def __init__(self, msg=None):
		self.msg = msg
	def __str__(self):
		if self.msg:
			return self.msg
		else:
			return "unknown error"

if __name__ == "__main__":
	logger = Log("testfile","casename").getlog()
	logger.info("hello msg!!!")
	count = 1
	while 1:
		time.sleep(0.5)
		logger.info("run %d"%count)
		count += 1
	try:
		if False:
			pass
		else:
			raise CustomError("raised msg!!!")
	except BaseException as msg:
		logger.exception(msg)
		pass
	print("#")
