import sys
import multiprocessing
from multiprocessing import Pool
from multiprocessing.pool  import ThreadPool
import time

import numpy as np

def func(msg):
    #while True:
    #    continue
    return multiprocessing.current_process().name + '-' + msg

def loop():
    while True:
        continue

def func_numpy(n=100000,seed=0):
    np.random.seed(seed)
    return np.random.random(n) * np.random.random(n)

def worker(i):
    for j in range(10):
        X1 = np.asmatrix(np.random.rand(600,600))
        np.linalg.svd(X1)
    return 0


import signal
def init_worker():
    signal.signal(signal.SIGINT, signal.SIG_IGN)
    #signal.signal(signal.SIGTERM)

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

class Threadone(object):
    def __init__(self,nthreads=8):
        self.nthreads = nthreads
        self.pool     = ThreadPool(self.nthreads)
        self.store    = []
        self.results  = []
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
    #mp = MPone(8)
    mp = Threadone(8)
    for i in range(20):
        msg = "hello %d"%i
        #mp.run(func,[msg,])
        mp.run(worker,[i,])
    mp.join()
    for ret in mp.results:
        print(ret)
    


