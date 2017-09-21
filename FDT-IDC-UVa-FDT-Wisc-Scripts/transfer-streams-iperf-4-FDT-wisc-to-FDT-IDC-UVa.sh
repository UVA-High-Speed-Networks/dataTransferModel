#Transfers file from FDT wisc --> FDT Uva, FDT wisc --> IDC UVs using iperf3 (from root) and scp (from uvauser)

#cd /home/uvauser/sm8kk
file="3_GB_file.txt"
FDT_UVa="fdt-uva.dynes.virginia.edu"
IDC_UVa="idc-uva.dynes.virginia.edu"
LOG_FDT_iperf="iperf_log_wisc_fdt_uva.txt"
LOG_IDC_iperf="iperf_log_wisc_idc_uva.txt"

FDT_IP="128.143.231.105"
IDC_IP="128.143.231.110"

rm $LOG_FDT_iperf
rm $LOG_IDC_iperf

touch $LOG_FDT_iperf
touch $LOG_IDC_iperf


tmax=420 #5GB at min 100Mbps speed takes 400 seconds
transfer=1

#collecting rates from 40 such transfers
while [ $transfer -lt 41 ]; do
    echo "Begin transfer $transfer"
    #Run iperf3 and collect logs
    #FDT-wisc --> FDT-UVa

    sync #sync to disk
    echo 3 > /proc/sys/vm/drop_caches #drop cached files from previous transfers
    echo "Start transfer: $transfer" >> $LOG_FDT_iperf
    date >> $LOG_FDT_iperf 
    echo "Running iperf3 -c $FDT_IP -i 1 -P 4 -t $tmax -F $file"
    iperf3 -c $FDT_IP -i 1 -P 4 -t $tmax -F $file >> $LOG_FDT_iperf
    date >> $LOG_FDT_iperf 
    echo "End transfer: $transfer" >> $LOG_FDT_iperf


    #Run iperf3 and collect logs
    #FDT-wisc --> IDC-UVa

    sync #sync to disk
    echo 3 > /proc/sys/vm/drop_caches #drop cached files from previous transfers
    echo "Start transfer: $transfer" >> $LOG_IDC_iperf
    date >> $LOG_IDC_iperf 
    echo "Running iperf3 -c $IDC_IP -i 1 -P 4 -t $tmax -F $file"
    iperf3 -c $IDC_IP -i 1 -P 4 -t $tmax -F $file >> $LOG_IDC_iperf
    date >> $LOG_IDC_iperf 
    echo "End transfer: $transfer" >> $LOG_IDC_iperf
    
    #Run scp and collect logs
    #FDT-wisc --> FDT-UVa

    #sync #sync to disk
    #echo 3 > /proc/sys/vm/drop_caches #drop cached files from previous transfers
    #su uvauser
    #echo "Start transfer: $transfer" >> $LOG_FDT_scp
    #date >> $LOG_FDT_scp
    #echo "Running scp -v $file uvauser@fdt-uva.dynes.virginia.edu:/home/uvauser"
    #scp -v $file uvauser@fdt-uva.dynes.virginia.edu:/home/uvauser 2>&1 | grep "Trans" >> $LOG_FDT_scp
    #date >> $LOG_FDT_scp 
    #echo "End transfer: $transfer" >> $LOG_FDT_scp
    
    echo "End transfer $transfer"
    transfer=$((transfer+1))
    echo "Sleep for 25 minutes..."
    sleep 1500
done
