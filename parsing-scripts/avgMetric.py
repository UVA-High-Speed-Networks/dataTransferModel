from __future__ import division
import sys
import numpy as np
# Open the file
f = open(str(sys.argv[1]), 'r')
lines = f.readlines()
f.close()

util = []

for l in lines:
    util.append(float(l))
#print cpuBusy
print np.mean(util)
