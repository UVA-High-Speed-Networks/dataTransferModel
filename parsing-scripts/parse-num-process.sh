fileName=$1
cat $fileName | grep "Num process" | awk 'BEGIN {FS = " "}; {print $3}' > numProcesses.txt
avgNumProc=`python avgMetric.py numProcesses.txt`
echo $avgNumProc
