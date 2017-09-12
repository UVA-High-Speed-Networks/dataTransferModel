from __future__ import division
import sys
dutyCy=float(sys.argv[1])/100
tm=float(sys.argv[2])
#the stress on disk with stress -d 2 -t 10, runs
slTm = (tm/dutyCy - tm)
print str(int(slTm))
