from __future__ import division
import sys
import numpy as np
# Open the file
f = open(str(sys.argv[1]), 'r')
lines = f.readlines()
f.close()

cpuBusy = []
max = 100

for l in lines:
    if(l.strip() == ''):
        continue;

    cpuBusy.append(max - float(l))
#print cpuBusy
print np.mean(cpuBusy)
