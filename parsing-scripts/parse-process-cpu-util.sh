fileName=$1
processName=$2
cat $fileName | grep $processName | tr -s " " | awk 'BEGIN {FS = " "}; {print $9}' > processCpuUtil.txt
avgProcCpu=`python avgMetricNonZero.py processCpuUtil.txt`
echo $avgProcCpu
