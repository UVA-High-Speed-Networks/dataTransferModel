fileName=$1
cat $fileName | grep "iperf3" | tr -s " " | awk 'BEGIN {FS = " "}; {print $9}' > processCpuUtil.txt
avgProcCpu=`python avgMetric.py processCpuUtil.txt`
echo $avgProcCpu
