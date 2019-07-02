import sys

def strtri(n,sep=','):
	if type(n) == int or type(n) == long:
		pass
	else:
		return None
	s = str(abs(n))[::-1]
	groups = []
	i = 0
	while i < len(s):
		groups.append(s[i:i+3])
		i+=3
	retval = sep.join(groups)[::-1]
	if n < 0:
		return '-%s' % retval
	else:
		return retval

def f2str(f):
	return "%.3f"%f

if __name__ == "__main__":
	print strtri(423)
	print strtri(21313)
	print strtri(-411)
	print strtri(-41)
	print strtri(-132131)



