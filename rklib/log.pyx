import sys
import os
import logging
def initlog(logfile):
	logger = logging.getLogger()
	"logging support Handler, such as FileHandler, SocketHandler,SMTPHandler et al. logfile is a globle variable such as 'crawl.log'"
	#logger1 = logging.getLogger("error")
	hdlr = logging.FileHandler(logfile)
	formatter = logging.Formatter('%(asctime)s [%(levelname)s] %(message)s')
	hdlr.setFormatter(formatter)
	logger.addHandler(hdlr)
	logger.setLevel(logging.NOTSET)
	#logger.setLevel(logging.NOTSET)
	##logger.error(message)
	##logger.info(message)
	##logger.exception(e)
	## logging.shutdown()
	return logger
def closelog():
	return logging.shutdown()

if __name__ == "__main__":
	logger = initlog("test.log")
	logger.info("Task begin:")
	try:
		1+"21313"
	except Exception,e:
		logger.exception(e)
	print closelog()
#else:
#	module_debug = initlog("pymodule_debug.log")
#	os.chmod("pymodule_debug.log",0b110110110)
