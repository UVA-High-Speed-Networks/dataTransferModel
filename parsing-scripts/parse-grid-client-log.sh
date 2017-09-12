fileName=$1
cat $fileName | tr -d '\r' | tr -s " " | sed 's/inst/\n/g' | sed '/^$/d' > temp_grid.txt
startTm=`head -1 temp_grid.txt | awk 'BEGIN {FS = " "}; {print $3}'`
endTm=`tail -1 temp_grid.txt | awk 'BEGIN {FS = " "}; {print $3}'`
transferSz=`tail -2 temp_grid.txt | head -1 |  awk 'BEGIN {FS = " "}; {print $1}'`
op=`python getRateDur.py $startTm $endTm $transferSz`
echo $op
