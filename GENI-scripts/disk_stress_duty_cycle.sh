dutyCycle=$1
filePath="/users/sm8kk0/scripts"
file="$filePath/transfer_end_flag.txt"
rm $file
while [ ! -f "$file" ]
do
  echo "Running stress with 2 HDD write workers.."
  stress -d 2 -t 10 > $filePath/temp.txt
  #test right after stress utility and exit if there is no need to sleep
  if [ -f "$file" ]
  then
    break;
  fi

  tm=`cat $filePath/temp.txt | grep completed | awk 'BEGIN {FS = " "}; {print $8}' | tr -d "s"`
  #compute sleep time based on duty cycle
  echo "Time taken: $tm sec"
  slTm=`python $filePath/sleepTime.py $dutyCycle $tm`
  echo "Sleeping for: $slTm"
  sleep $slTm
done
echo "Disk util with DTC $1 died"
