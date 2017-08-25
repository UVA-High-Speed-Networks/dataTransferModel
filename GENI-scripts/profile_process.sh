name=$1
echo "Executing top -bn1 | grep $name"
while true; do 
  N=`ps -fe | wc -l`
  echo "Num process: $N"
  top -bn1 | grep $name
  sleep 1
done
