# -*- coding: utf-8 -*-
import os,signal,time
import threading
import sys
def foreverLoop():
	while 1:
		time.sleep(1)

class Watcher:
	"""this class solves two problems with multithreaded 
	programs in Python, (1) a signal might be delivered 
	to any thread (which is just a malfeature) and (2) if 
	the thread that gets the signal is waiting, the signal 
	is ignored (which is a bug). 
					  
	The watcher is a concurrent process (not thread) that 
	waits for a signal and the process that contains the 
	threads.  See Appendix A of The Little Book of Semaphores. 
	http://greenteapress.com/semaphores/ 
									   
	I have only tested this on Linux.  I would expect it to 
	work on the Macintosh and not work on Windows. 
	"""  
	def __init__(self):
		""" Creates a child thread, which returns.  The parent 
	    thread waits for a KeyboardInterrupt and then kills 
		the child thread. 
		""" 
		self.child = os.fork()
		if self.child == 0:
			return
		else: self.watch()
	def watch(self):
		try:
			os.wait()
		except KeyboardInterrupt:
			sys.stderr.write("KeyBoardInterrupt\n")
			self.kill()
		sys.exit(1)
	def kill(self):
		try:
			os.kill(self.child, signal.SIGKILL)
		except OSError: pass

class thread_rets(object):
	def __init__(self):
		self.rets = 0
		self.lock = threading.Lock()
	def increase(self,ret):
		self.lock.acquire()
		try:
			self.rets += ret
		finally:
			self.lock.release()


if __name__ == "__main__":
	Watcher()#watch function must be in front of threads_tasks
	tasks = []
	for i in range(4):
		thread_=threading.Thread(target=foreverLoop)
		tasks.append(thread_)
		thread_.start()
	for i in range(4):
		tasks[i].join()

