procName=$1
fileName=$2

cat $fileName | grep $procName | tr -s " " | awk 'BEGIN {FS = " "}; {print $5}' > temp-rd-speed.txt
readSpeed=`python avgDiskSpeed.py temp-rd-speed.txt`
echo $readSpeed
