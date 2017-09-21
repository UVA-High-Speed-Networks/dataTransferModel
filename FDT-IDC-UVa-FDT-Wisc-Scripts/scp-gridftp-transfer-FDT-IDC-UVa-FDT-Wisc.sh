#Transfers file from FDT wisc --> FDT Uva, FDT wisc --> IDC UVa using iperf3 (from root) and scp (from uvauser)

#cd /home/uvauser/sm8kk
file="5_GB_file.txt"
FDT_UVa="fdt-uva.dynes.virginia.edu"
IDC_UVa="idc-uva.dynes.virginia.edu"
LOG_FDT_scp="scp_log_wisc_fdt_uva.txt"
LOG_IDC_scp="scp_log_wisc_idc_uva.txt"
LOG_FDT_grid="grid_log_wisc_fdt_uva.txt"

FDT_IP="128.143.231.105"
IDC_IP="128.143.231.110"

rm $LOG_FDT_scp
rm $LOG_IDC_scp
rm $LOG_FDT_grid

touch $LOG_FDT_scp
touch $LOG_IDC_scp
touch $LOG_FDT_grid


transfer=1
cpu=100
NTransfers=51

#collecting rates from 40 such transfers
while [ $transfer -lt $NTransfers ]; do
    echo "Begin transfer $transfer"
    #Run scp and collect logs
    #FDT-UVa --> FDT-wisc, load the sending host with stress -c 100
    echo "ssh uvauser@$FDT_UVa "stress -c $cpu" &"
    ssh uvauser@$FDT_UVa "stress -c $cpu" &
    sync #sync to disk
    #sudo echo 3 > /proc/sys/vm/drop_caches #drop cached files from previous transfers
    echo "Start transfer: $transfer" >> $LOG_FDT_scp
    date >> $LOG_FDT_scp 
    echo "Running scp -v uvauser@$FDT_UVa:/home/uvauser/$file ."
    scp -v uvauser@$FDT_UVa:/home/uvauser/$file . 2>&1 | grep "Transferred" >> $LOG_FDT_scp
    date >> $LOG_FDT_scp 
    echo "End transfer: $transfer" >> $LOG_FDT_scp
    echo "ssh uvauser@$FDT_UVa "pkill stress""
    ssh uvauser@$FDT_UVa "pkill stress"

    #Run scp and collect logs
    #IDC-UVa --> FDT-Wisc

    sync #sync to disk
    #sudo echo 3 > /proc/sys/vm/drop_caches #drop cached files from previous transfers
    echo "Start transfer: $transfer" >> $LOG_IDC_scp
    date >> $LOG_IDC_scp 
    echo "Running scp -v uvauser@$IDC_UVa:/home/uvauser/$file ."
    scp -v uvauser@$IDC_UVa:/home/uvauser/$file . 2>&1 | grep "Transferred" >> $LOG_IDC_scp
    date >> $LOG_IDC_scp 
    echo "End transfer: $transfer" >> $LOG_IDC_scp
    
    #Run gridFTP
    #FDT-wisc --> FDT-UVa, 4 streams, load FDT-Uva again
    echo "ssh uvauser@$FDT_UVa "stress -c $cpu" &"
    ssh uvauser@$FDT_UVa "stress -c $cpu" &
    sync #sync to disk
    #sudo echo 3 > /proc/sys/vm/drop_caches #drop cached files from previous transfers
    echo "Start transfer: $transfer" >> $LOG_FDT_grid
    date >> $LOG_FDT_grid
    echo "Running globus-url-copy -vb -p 4 file:/home/uvauser/sm8kk/$file ftp://$FDT_IP:50001/home/uvauser/data.out"
    globus-url-copy -vb -p 4 file:/home/uvauser/sm8kk/$file ftp://$FDT_IP:50001/home/uvauser/data.out >> $LOG_FDT_grid
    date >> $LOG_FDT_grid 
    echo "End transfer: $transfer" >> $LOG_FDT_grid
    echo "ssh uvauser@$FDT_UVa "stress -c $cpu""
    ssh uvauser@$FDT_UVa "pkill stress"

    echo "End transfer $transfer"
    transfer=$((transfer+1))
    echo "Sleep for 25 minutes..."
    sleep 1500
done
