from __future__ import division
import sys
import numpy as np
# Open the file
startTm = float(sys.argv[1])
endTm = float(sys.argv[2])
transferSz = float(sys.argv[3])
dur = endTm - startTm
rate = transferSz*8/dur
print str(dur) + "," + str(transferSz) + "," + str(rate)
