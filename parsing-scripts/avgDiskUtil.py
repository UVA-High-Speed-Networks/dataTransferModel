from __future__ import division
import sys
import numpy as np
# Open the file
f = open(str(sys.argv[1]), 'r')
lines = f.readlines()
f.close()

header=True
diskBusy = []
max = 100
string="%util"
tempUtil=[] #stores the disk utilization every second, for every device, whose utilization is > 0
#we will use the average utilization of the devices by calculating the average for devices that
#have utilization of more than 0%

empty=1
for l in lines:
    if(l.strip() == ''):
        continue;

    if(header == True):
        header= False
        continue;
    
    if(l[:-1] == string):
        if(empty == 0):
            diskBusy.append(np.mean(tempUtil))
        else:
            diskBusy.append(0)
        #print tempUtil
        tempUtil = []
        empty=1
    else:
        util=float(l)
        if (util > 0):
            tempUtil.append(util)
            empty=0
    
#print diskBusy
print np.mean(diskBusy)
