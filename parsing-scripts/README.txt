Log parsing to find the resource utilization of the transfer hosts:
run as: ./getTransferFeaturesDetail.sh <outputfile>, change the path in <outputfile> to the location of the
sar, iostat, and profiler logs.

For getting detailed disk read and write speed for the data transfer application (setup used was that of cloudlab)
./getTransferFeaturesDetailCloudLabDisk.sh cloudLabTransferFeatures.txt
