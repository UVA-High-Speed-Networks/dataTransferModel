Log parsing to find the resource utilization of the transfer hosts:

scripts:
1. getTransferFeatures.sh: Extracts the transfer features [transfer,sendCpuUtil,sendDiskUtil,recvCpuUtil,recvDiskUtil,dur,size,rate] from sar and iperf logs from the sender and receiver.
Change LOG_PATH to the path of these logs.
Usage: ./getTransferFeaturesDetail.sh <outputfile>

2. getTransferFeaturesDetail.sh: Similar to (1) but extracts more feature details like [transfer,sendCpuUtil,sendDiskUtil,sendProcNum,sendTransferCpu,recvCpuUtil,recvDiskUtil,recvProcNum,recvTransferCpu,dur,size,rate]. Data transfer rate is parsed from iperf logs. Usage is similar to (1).

3. getTransferFeaturesDetailCloudLabDisk.sh: Extracts data transfer features [transfer,sendCpuUtil,sendDiskUtil,sendProcNum,sendTransferCpu,transferDiskRead,recvCpuUtil,recvDiskUtil,recvProcNum,recvTransferCpu,transferDiskWrite,dur,size,rate] from sar, top, iotop logs at the sender and receiver for hosts that are in cloudlab. The data transfer application used is gridFTP, hence a separate parser is needed to parse the client side gridFTP logs. Note that in Ubuntu, iperf disk to disk transfers perform worse when compared to gridFTP transfer. This is however not true for Centos hosts where iperf does not have a lower performance when compared to gridFTP.
Usage is siilar to (1).
For getting detailed disk read and write speed for the data transfer application (setup used was that of cloudlab)
./getTransferFeaturesDetailCloudLabDisk.sh cloudLabTransferFeatures.txt

All these 3 scrpts for parsing use the other helper scripts for parsing sar, iperf, iotop, top, and gridFTP logs. They are: avgCpuUtil.py, avgDiskSpeed.py, avgDiskUtil.py, avgMetric.py, avgMetricNonZero.py, getRateDur.py, parse-grid-client-log.sh, parse-iotop-disk-speed-read.sh, parse-iotop-disk-speed-write.sh, parse-iperf-log-disk.sh, parse-num-process.sh, parse-process-cpu-util-multi-proc.sh, parse-process-cpu-util.sh, parse-sar-cpu-util.sh, parse-sar-disk-util.sh.

Feature description:

transfer: Indicates the data transfer number. It is unique.

sendCpuUtil: Average of the total CPU utilization (100 - CPU idle time%) taken over all the cores at the sender.

sendDiskUtil: Average of the total disk utilization by the sender.

sendProcNum: Average of the total number of processes running at the sender.

sendTransferCpu: Average CPU utilization by the data transfer process (adjusted for multic-core operation, but found that the data transfer used only one core) at the sender.

transferDiskRead: Average disk read speed in bps by the data transfer process at the sender.

recvCpuUtil: Average of the total CPU utilization (100 - CPU idle time%) taken over all the cores at the receiver.

recvDiskUtil: Average of the total disk utilization by the receiver.

recvProcNum: Average of the total number of processes running at the receiver.

recvTransferCpu: Average CPU utilization by the data transfer process (adjusted for multic-core operation, but found that the data transfer used only one core) at the receiver.

transferDiskWrite: Average disk write speed in bps by the data transfer process at the receiver.

dur: duration of the transfer

size: size of the transfer

rate: Average rate of the transfer

