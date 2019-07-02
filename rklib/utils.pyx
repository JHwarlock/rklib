import sys
import os
import log
import time
import signal
import shutil
from operator import itemgetter, attrgetter
import time

from functools import wraps

## get cost name
def ctimer(function):
	@wraps(function)
	def ftimer(*args, **kwargs):
		t0 = time.time()
		result = function(*args, **kwargs)
		t1 = time.time()
		sys.stderr.write("[INFO] '%s' running cost: %s seconds\n" %(function.func_name, str(t1-t0)))
		return result
	return ftimer

def requirtasks(fn): # for qsubid
	f = file(fn,"r")
	task_sh = []
	for line in f:
		tasksh = line.rstrip("\n")
		task_sh.append(tasksh)
	f.close()
	ret = 1
	leng = len(task_sh)
	breaksignal = 1
	while breaksignal:
		flagok = 0
		time.sleep(1)
		for tsh in task_sh:
			if not os.path.isfile(tsh):
				breaksignal = 0;
				sys.stderr.write("[ERROR] '%s' could not be found\n"%tsh)
				break
			if os.path.isfile(tsh+".ok"):
				flagok += 1
			if os.path.isfile(tsh+".fail"):
				sys.stderr.write("[ERROR] '%s' failed\n"%tsh)
				breaksignal = 0
				break
		if flagok == leng:
			ret = 0; breaksignal = 0
	return ret

def combinehead(title,header,des):
	strout = ""
	strout = title + "\n"
	strout += "\n".join(des) + "\n"
	strout += header + "\n"
	return strout

def parserhead(f):
	f.seek(0)
	title = ""
	des    = []
	header  = ""
	
	for line in f:
		if line.startswith("###"): des.append(line.rstrip("\n"))
		elif line.startswith("##"): title = line.rstrip("\n")
		elif line.startswith("#"): header = line.rstrip("\n")
		else:
			break
	f.seek(0)
	return title,header,des

def us_sort(arr,*pos):
	"""
	a = [[1,2,3,4],[2,1,2,3]]
	us_sort(a,0,1,2)
	"""
	##here pos is array: like [1,2,3,4] 
	arr = sorted(arr,key=itemgetter(*pos))
	return arr
def us_rsort(arr,*pos):
	arr = sorted(arr,key=itemgetter(*pos),reverse=True)
	return arr

###this is not used again, please use the libsci enrich module
def cummin_small_large(FDR_arr):
	leng = len(FDR_arr)
	if FDR_arr[leng-1] > 1:
		FDR_arr[leng-1] = 1.000000
	for i in xrange(leng-1):
		index = leng-1-i
		index_left = index -1
		if FDR_arr[index_left] > FDR_arr[index]:
			FDR_arr[index_left] = FDR_arr[index]
	return FDR_arr

try:
	from ConfigParser import ConfigParser
except Exception,e:
	sys.stderr.write("[CONFIG_ERROR]: Cann't import the 'Config Module'\n")
	#log.error_log.error("[Config_Error]: Cann't import the 'Config Module'")
	#log.module_debug.exception(e)
	sys.exit(1)

def piperead(fn):
	"""
	f = piperead(sys.argv[1])
	for line in f:

	"""
	if fn == "-":
		f = sys.stdin
	else:
		f = file(fn,"r")
	return f

class config_init():
	def __init__(self):
		self.h_config = {}
		#try:
		self.config = ConfigParser()
		#except Exception,e:
		#log.error_log.error("Parser error")
		#sys.exit("Error")
	def parse(self,config_fn,**kwargs):
		##classitems, name,key=name;
		self.config.read(config_fn)
		for key in kwargs:
			self.h_config[key] = self.config.get(kwargs[key],key)
	def destroy(self):
		del self.config
		del self.h_config

#def get_config(config_fn="/home/zqrong/bin/pipes/exon_sequnce_config.txt"):
#	h_config = {}
#	config = ConfigParser()
#	if config.read(config_fn):
#		try:
#			h_config['bwa'] = config.get('aln_software','bwa')
#			h_config['samtools'] = config.get('variant_calling_software','samtools')
#			h_config['annovar'] = config.get("anno",'annovar_path')
#		except Exception,e:
#			sys.stderr.write("[Config_Error]: "+str(e)+"\n")
#			return None
#	else:
#		sys.stderr.write("[Config_Error]: Cann't find Config File '"+config_fn+"\n")
#		return None
#	return h_config

def parse_filename(fn):
	try:
		prefix,suffix = os.path.splitext(fn)
	except:
		return None
	return [prefix,suffix]

def dirDetectCreate(dir):
	if not os.path.isdir(dir):
		try:
			os.mkdir(dir)
		except:
			sys.stderr.write("[ERROR] Cannot creat dir: %s!\n"%(dir))
			return 1
	return 0
def getfileoutprefix(outdir,outprefix):
	if dirDetectCreate(outdir):
		return None
	return os.path.sep.join([outdir,outprefix])

def delfile(fn):
	if os.path.isfile(fn):
		os.remove(fn)
	return 0

def movefile(old,new):
	if os.path.isfile(old):
		shutil.move(old,new)
	return 0
def copyfile(src,dst):
	if os.path.isfile(src):
		shutil.copy(src,dst)
	return 0

def rename(old,new):
	if os.path.isfile(old):
		os.rename(old,new)
	return 0

def isfile(fn):
	if os.path.isfile(fn):
		return 0
	else:return 1

def get_pathfile(fn):
	absfile = os.path.abspath(fn)
	path = os.path.dirname(absfile)
	fprefix, fsuffix = parse_filename(os.path.basename(absfile))
	return path,fprefix,fsuffix

def onsignal_term(a,b):
	sys.stderr.write("[ERROR] Program interrupt\n")
	sys.exit(1)

def thread_term(signum, frame):
	sys.stderr.write("[ERROR] Program interrupt\n")
	sys.exit(1)

def monitor_controlC(thread=0):
	if thread:
		signal.signal(signal.SIGINT,thread_term)
		signal.signal(signal.SIGTERM,thread_term)
		signal.signal(signal.SIGPIPE,thread_term)
	signal.signal(signal.SIGINT,onsignal_term)
	signal.signal(signal.SIGTERM,onsignal_term)
	signal.signal(signal.SIGPIPE,onsignal_term)

if __name__ == "__main__":
	"""
	exon_pipe_config = config_init()
	h = {"bwa":"aln_software","samtools":"variant_calling_software","annovar":"anno"}
	#exon_pipe_config.parse("~/lib/config_test.txt",**h)
	exon_pipe_config.parse(sys.argv[1],**h)
	print exon_pipe_config.h_config
	exon_pipe_config.destroy()
	print exon_pipe_config
	#print exon_pipe_config.h_config
	#print exon_pipe_config.config
	del exon_pipe_config
	#print exon_pipe_config
	"""
	a = [["AAA",2,6,11],["AAB",2,5,11],["AAB",2,7,11]]
	print us_rsort(a,2)

