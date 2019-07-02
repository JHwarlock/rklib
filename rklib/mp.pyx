import sys
import multiprocessing
from multiprocessing import Pool
from multiprocessing.pool  import ThreadPool
import time

def func(msg):
	#b = 0.0
	#for i in xrange(100000):
	#	for j in xrange(10000):
	#		b += 1
	return multiprocessing.current_process().name + '-' + msg

import signal
def init_worker():
	signal.signal(signal.SIGINT, signal.SIG_IGN)


class MPone(object):
	def __init__(self,nprocessor=8): # method = process or thread
		self.nprocessor = nprocessor
		self.pool = Pool(self.nprocessor,init_worker)
		self.store = []
		self.results = []
	def run(self,func,*arg):
		self.store.append(self.pool.apply_async(func,*arg))
	def join(self):
		try:
			time.sleep(0.01)
		except KeyboardInterrupt:
			self.pool.terminate()
			self.pool.join()
		else:
			self.pool.close()
			self.pool.join()
			for ret in self.store:
				self.results.append(ret.get())
		return 0




if __name__ == "__main__":
	mp = MPone(8)
	for i in xrange(20):
		msg = "hello %d"%i
		mp.run(func,[msg,])
	mp.join()
	for ret in mp.results:
		print ret
	


