from __future__ import division
import sys
import numpy as np
# Open the file
f = open(str(sys.argv[1]), 'r')
lines = f.readlines()
f.close()

util = []

for l in lines:
    if(l.strip() == ''):
        continue;
    x=float(l)
    if(x == 0):
        continue;
    util.append(x)
#print cpuBusy
print np.mean(util)
