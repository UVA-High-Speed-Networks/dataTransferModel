fileName=$1

l=`cat $fileName | grep "receiver" | tr -s " "`
size=`echo $l | awk 'BEGIN {FS = " "}; {print $5}'`
sizeMet=`echo $l | awk 'BEGIN {FS = " "}; {print $6}' | cut -c1-1`
rate=`echo $l | awk 'BEGIN {FS = " "}; {print $7}'`
rateMet=`echo $l | awk 'BEGIN {FS = " "}; {print $8}' | cut -c1-1`
dur=`echo $l | awk 'BEGIN {FS = " "}; {print $3}' | awk 'BEGIN {FS = "-"}; {print $2}'`
echo "$dur,$size$sizeMet,$rate$rateMet"
