fileName=$1
processName=$2
cat $fileName | grep -A1 "process" | grep $processName | tr -s " " | awk 'BEGIN {FS = " "}; {print $9}' > processCpuUtilMulti.txt
avgProcCpu=`python avgMetricNonZero.py processCpuUtilMulti.txt`
echo $avgProcCpu
