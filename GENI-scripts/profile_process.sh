name=$1
echo "Executing top -bn1 | grep $name"
filePath="/users/sm8kk0/scripts"
file="$filePath/transfer_end_flag.txt"
rm $file
while [ ! -f "$file" ]
do
  N=`ps -fe | wc -l`
  echo "Num process: $N"
  top -bn1 | grep $name
  sleep 1
done
echo "Profiler gathering process info died"
