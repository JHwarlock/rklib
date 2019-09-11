import gzip
import bz2
import sys
import tarfile
from os import linesep
def cfread(fname,mode,level=6):
	fp = None
	try:
		if fname.endswith(".gz"):
			fp = gzip.open(fname,mode+"b",level)
		elif fname.endswith(".bz2"):
			fp = bz2.BZ2File(fname)
		else:
			fp = open(fname,mode)
		sys.stderr.write("[INFO] read file '%s', %s%s"%(fp,["Success","Failed"][fp is None],linesep))
	except Exception as error:
		sys.stderr.write("[ERROR] %s%s"%(error,linesep))
	return fp

def tarxpath(fn,path):
	t = tarfile.open(fn,"r:*")
	t.extractall(path = path)
	t.close()
	return 0

def gz_file(fq_file,mode,level=6):
	try:
		if fq_file.endswith(".gz"):
			fq_fp = gzip.open(fq_file,mode+"b",level)
		else:
			sys.stderr.write("[INFO] read file '%s'%s"%(fq_file,linesep))
			fq_fp = open(fq_file,mode)
	except:
		sys.stderr.write("[Error] Fail to IO file: %s%s"%(fq_file,linesep))
		sys.exit(1)
	return fq_fp


def bz2file(f):
	fz = None
	if f.endswith(".bz2"):
		fz = bz2.BZ2File(f)
	else:
		sys.stderr.write("[Error] Fail to IO file: %s%s"%(f,linesep))
		sys.exit(1)
	return fz

def runtest(filename):
	f = cfread(filename,"r")
	print(f)

if __name__ == "__main__":
	runtest(sys.argv[1])


