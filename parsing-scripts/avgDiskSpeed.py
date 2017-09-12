from __future__ import division
import sys
import numpy as np
# Open the file
f = open(str(sys.argv[1]), 'r')
lines = f.readlines()
f.close()

speed = []
KB=1000*8
for l in lines:
    if(l.strip() == ''):
        continue;
    speed.append(float(l))
#print cpuBusy
print str(np.mean(speed)*KB)
