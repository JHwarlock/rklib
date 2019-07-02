from math import floor
import sys
class ProgressBar():
	def __init__(self, width=100,xmax=100,msg = "Task"):
		self.pointer = 0
		self.width = width
		self.xmax = xmax
		self.x = 0
		self.msg = msg
		self.len = 0
		sys.stderr.write("%s start:\n"%self.msg)
		sys.stderr.flush()
		self.current = 0
	def __call__(self):
		# x in percent
		self.x += 1
		xm = float(self.x)/self.xmax
		#if xm-self.current <= 0.25 and xm < 0.99:
		#	return 0
		self.pointer = int(self.width*(xm))
		sys.stderr.write("\b"*self.len)
		sys.stderr.flush()
		strout = "|" + "#"*self.pointer + "-"*(self.width-self.pointer)+"|  %.2f %% done" %(xm*100)
		self.len = len(strout)
		sys.stderr.write(strout)
		sys.stderr.flush()
		self.current = xm
		return 0
	def end(self):
		sys.stderr.write("\n%s done\n"%self.msg)
		sys.stderr.flush()

if __name__ == '__main__':
	import time, os
	pb = ProgressBar(xmax=101*33)
	for i in range(101):
		for j in xrange(33):
			#print pb()
			pb()
			time.sleep(0.01)
	pb.end()
