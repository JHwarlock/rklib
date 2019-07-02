#!/usr/bin/env python
# -*- coding: UTF-8 -*-

"""
just for call
"""

import sys
from distutils.core import setup,Extension
from Cython.Build import cythonize

package_list = ["rklib"]
package_dir = {"rklib": "rklib"}


#exts = cythonize([Extension("fib", sources=["cfib.c", "fib.pyx"])])

metadata = {
		"name":"rklib",
		"version":"1.0.0",
		'description': "rklib",
		'long_description': __doc__,
		'author': "rongzhengqin",
		'author_email': "rongzhengqin@basepedia.com",
		'license': "MIT",
		'platforms': ["Linux","Mac OS-X","UNIX"],
		'url': "https://github.com/zju3351689/rklib",
		'packages': package_list,
		'package_dir': package_dir,
		'data_files': [],
		'ext_modules': cythonize("*/*.pyx"),
		}

if __name__ == '__main__':
	dist = setup(**metadata)


