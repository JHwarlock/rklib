import gzip
import bz2
import sys
import tarfile

def cfread(fname,mode,level=6):
	fp = None
	if fname.endswith(".gz"):
		fp = gzip.open(fname,mode+"b",level)
	elif fname.endswith(".bz2"):
		fp = bz2.BZ2File(fname)
	else:
		fp = file(fname,mode)
	sys.stderr.write("[INFO] read file '%s', %s\n"%(fp,["Success","Failed"][fp==None]))
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
			sys.stderr.write("[INFO] read file '%s'\n"%fq_file)
			fq_fp = file(fq_file,mode)
	except:
		sys.stderr.write("[Error] Fail to IO file: %s\n"%(fq_file))
		sys.exit(1)
	return fq_fp


def bz2file(f):
	fz = None
	if f.endswith(".bz2"):
		fz = bz2.BZ2File(f)
	else:
		sys.stderr.write("[Error] Fail to IO file: %s\n"%(f))
		sys.exit(1)
	return fz

if __name__ == "__main__":
	f = bz2file(sys.argv[1])
	count = 0
	for line in f:
		print line.strip() 
		if count == 15:
			break
		count += 1
