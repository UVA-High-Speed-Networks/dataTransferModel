fileName=$1

#sar logs:
#Average CPU utilization:
cat $fileName | grep "all" | tr -s " " | awk 'BEGIN {FS = " "}; {print $9}' > cpu-all-idle-util.txt
cpuUtilMean=`python avgCpuUtil.py cpu-all-idle-util.txt`
echo $cpuUtilMean

