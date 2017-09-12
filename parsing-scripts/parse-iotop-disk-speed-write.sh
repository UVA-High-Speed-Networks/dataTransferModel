procName=$1
fileName=$2

cat $fileName | grep $procName | tr -s " " | awk 'BEGIN {FS = " "}; {print $7}' > temp-wr-speed.txt
writeSpeed=`python avgDiskSpeed.py temp-wr-speed.txt`
echo $writeSpeed
