filename=$1

#Average disk utilization:
cat $filename | awk '/DEV/' RS= | tr -s " " | awk 'BEGIN {FS = " "}; {print $11}' > disk-all-busy-util.txt
diskUtilMean=`python avgDiskUtil.py disk-all-busy-util.txt`
echo $diskUtilMean

