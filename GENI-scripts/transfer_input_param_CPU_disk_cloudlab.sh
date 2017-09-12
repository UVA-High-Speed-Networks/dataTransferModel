#Transfers file from Node1 --> Node2, using gridFTP 1 stream

#cd /home/uvauser/sm8kk
file="/dataTransferDisk/30_GB_file"
paramFile=$1
wc_out=$(wc -l $paramFile)
length=($wc_out)
FDT_UVa="fdt-uva.dynes.virginia.edu"
LOG_PATH_FDT="/home/sm8kk/FDT-IDC-pS-Modelling/logs"
LOG_PATH_CLD="/users/sm8kk0/logs"
FDT_PRIV_KEY="/home/sm8kk/.ssh/yes"
REMOTE_SCRIPT_PATH="/users/sm8kk0/scripts"

FDT_MGMT_IP="128.143.231.105"
Node1="sm8kk0@c220g1-031102.wisc.cloudlab.us"
Node2="sm8kk0@c220g1-031107.wisc.cloudlab.us"
NODE1_IP="10.10.1.1"
NODE2_IP="10.10.1.2"
zero=0
transfer=1
transferProcessApp="globus"
#ensure that the file transfer application is running: globus-gridftp-server -control-interface 10.10.1.2 -aa -p 5000 -log-transfer gridftp.log
for i in `seq 1 ${length[0]}`; do
    line=`head -$i $paramFile | tail -1`
    if [[ $line  == \#* ]]
    then
      echo "Header found"
      continue;
    fi
    
    transfer=`echo $line | awk 'BEGIN {FS = ","}; {print $1}'`
    sendCpu=`echo $line | awk 'BEGIN {FS = ","}; {print $2}'`
    sendIo=`echo $line | awk 'BEGIN {FS = ","}; {print $3}'`
    recvCpu=`echo $line | awk 'BEGIN {FS = ","}; {print $4}'`
    recvIo=`echo $line | awk 'BEGIN {FS = ","}; {print $5}'`
    
    echo "sendCpu = $sendCpu, sendIo = $sendIo, recvCpu = $recvCpu, recvIo = $recvIo"
    echo "Begin transfer $transfer"

    LOG_SEND_grid="grid_log_send_to_recv_transfer_"$transfer".txt"
    LOG_SEND_iostat="iostat_log_send_transfer_"$transfer".txt"
    LOG_SEND_sar="sar_log_send_transfer_"$transfer".txt"
    LOG_SEND_process_cpu="process_cpu_log_send_transfer_"$transfer".txt"
    LOG_SEND_iotop="iotop_log_send_transfer_"$transfer".txt"
    LOG_SEND_diskIO="diskio_log_send_transfer_"$transfer".txt"
    LOG_RECV_iostat="iostat_log_recv_transfer_"$transfer".txt"
    LOG_RECV_sar="sar_log_recv_transfer_"$transfer".txt"
    LOG_RECV_process_cpu="process_cpu_log_recv_transfer_"$transfer".txt"
    LOG_RECV_iotop="iotop_log_recv_transfer_"$transfer".txt"
    LOG_RECV_diskIO="diskio_log_recv_transfer_"$transfer".txt"
    FLAG_tf_end="transfer_end_flag.txt"

    #Kill the processes, just in case
    ssh -i $FDT_PRIV_KEY $Node1 "pkill sar"
    ssh -i $FDT_PRIV_KEY $Node1 "pkill iostat"
    ssh -i $FDT_PRIV_KEY $Node1 "sudo pkill iotop"
    ssh -i $FDT_PRIV_KEY $Node1 "pkill stress"
    ssh -i $FDT_PRIV_KEY $Node2 "pkill sar"
    ssh -i $FDT_PRIV_KEY $Node2 "pkill iostat"
    ssh -i $FDT_PRIV_KEY $Node2 "sudo pkill iotop"
    ssh -i $FDT_PRIV_KEY $Node2 "pkill stress"

    #Remove the file as a transfer end flag to synchronize stopping of other resource loads
    ssh -i $FDT_PRIV_KEY $Node1 "rm $REMOTE_SCRIPT_PATH/$FLAG_tf_end"
    ssh -i $FDT_PRIV_KEY $Node2 "rm $REMOTE_SCRIPT_PATH/$FLAG_tf_end"

    #log into the send node and start the cache flush process
    echo "ssh -i $FDT_PRIV_KEY $Node1 to clear the RAM so that the file is read from disk"
    #Clear PageCache, dentries and inodes
    ssh -i $FDT_PRIV_KEY -t "$Node1" 'sudo -i -u root sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"'
    ssh -i $FDT_PRIV_KEY $Node1 "sync" #sync to disk

    echo "Starting the logging for CPU, Disk, and Network Utilization using sar and iostat as background processes.."
    echo "Also start collecting CPU usage and num of processes time series.."
    echo "ssh -i $FDT_PRIV_KEY $Node1 to run: iostat, sar, profiler, iotop"
    ssh -i $FDT_PRIV_KEY $Node1 "iostat -x 1 > $LOG_PATH_CLD/$LOG_SEND_iostat" &
    ssh -i $FDT_PRIV_KEY $Node1 "sar -u -d -n DEV 1 $tmax > $LOG_PATH_CLD/$LOG_SEND_sar" &
    ssh -i $FDT_PRIV_KEY $Node1 "$REMOTE_SCRIPT_PATH/profile_process.sh $transferProcessApp > $LOG_PATH_CLD/$LOG_SEND_process_cpu" &
    ssh -i $FDT_PRIV_KEY $Node1 "sudo iotop -b -o -d 1.0 -t -k > $LOG_PATH_CLD/$LOG_SEND_iotop" &
    
    echo "ssh -i $FDT_PRIV_KEY $Node2 to run: iostat, sar, profiler, iotop"
    ssh -i $FDT_PRIV_KEY $Node2 "iostat -x 1 > $LOG_PATH_CLD/$LOG_RECV_iostat" &
    ssh -i $FDT_PRIV_KEY $Node2 "sar -u -d -n DEV 1 $tmax > $LOG_PATH_CLD/$LOG_RECV_sar" &
    ssh -i $FDT_PRIV_KEY $Node2 "$REMOTE_SCRIPT_PATH/profile_process.sh $transferProcessApp > $LOG_PATH_CLD/$LOG_RECV_process_cpu" &
    ssh -i $FDT_PRIV_KEY $Node2 "sudo iotop -b -o -d 1.0 -t -k > $LOG_PATH_CLD/$LOG_RECV_iotop" &

    echo "Stress CPU and IO at the send host based on the input parameters"
    if [ $sendCpu -ne $zero ]
    then
      echo "Execute $Node1: stress -c $sendCpu"
      ssh -i $FDT_PRIV_KEY $Node1 "stress -c $sendCpu" &
    fi

    if [ $sendIo -ne $zero ]
    then
      echo "Execute $Node1: ./disk_stress_duty_cycle.sh $sendIo"
      ssh -i $FDT_PRIV_KEY $Node1 "$REMOTE_SCRIPT_PATH/disk_stress_duty_cycle.sh $sendIo > $LOG_PATH_CLD/$LOG_SEND_diskIO" &
    fi

    echo "Stress CPU and IO at the receive host based on the input parameters"
    if [ $recvCpu -ne $zero ]
    then
      echo "Execute $Node1: stress -c $recvCpu"
      ssh -i $FDT_PRIV_KEY $Node2 "stress -c $recvCpu" &
    fi

    if [ $recvIo -ne $zero ]
    then
      echo "Execute $Node2: ./disk_stress_duty_cycle.sh $recvIo"
      ssh -i $FDT_PRIV_KEY $Node2 "$REMOTE_SCRIPT_PATH/disk_stress_duty_cycle.sh $recvIo > $LOG_PATH_CLD/$LOG_RECV_diskIO" &
    fi

    echo "Start transfer DISK to DISK: $transfer"
    echo "Running at send node: globus-url-copy -vb -p 1 file:$file ftp://10.10.1.2:5000/dataTransferDisk/30GB_data_out"
    #this is a blocking call

    ssh -i $FDT_PRIV_KEY $Node1 "echo "Start time: `date +%s`" > $LOG_PATH_CLD/$LOG_SEND_grid"
    ssh -i $FDT_PRIV_KEY $Node1 "globus-url-copy -vb -p 1 file:$file ftp://$NODE2_IP:5000/dataTransferDisk/30GB_data_out >> $LOG_PATH_CLD/$LOG_SEND_grid"
    ssh -i $FDT_PRIV_KEY $Node1 "echo "End time: `date +%s`" >> $LOG_PATH_CLD/$LOG_SEND_grid"
    echo "End transfer: $transfer, and send transfer end flag to send and receive nodes"
    #Create a file as a transfer end flag to synchronize stopping of other resource loads
    ssh -i $FDT_PRIV_KEY $Node1 "echo "Transfer ended" >> $REMOTE_SCRIPT_PATH/$FLAG_tf_end"
    ssh -i $FDT_PRIV_KEY $Node2 "echo "Transfer ended" >> $REMOTE_SCRIPT_PATH/$FLAG_tf_end"

    #kill the CPU and IO loads
    echo "Killing all stress utility at send and receive nodes"
    
    if [ $sendIo -ne $zero ]
    then
      echo "Execute $Node1: kill sendIO processes"
      #the script disk_stress_duty_cycle.sh should die automatically once it sees a transfer end flag
      #This step is to ensure that the disk stress process was killed, but if it kills the script while stress runs,
      #it may run forever. Therefore we leave it to the transfer end flag. Better to wait before starting the
      #next transfer.
      #ssh -i $FDT_PRIV_KEY $Node1 "$REMOTE_SCRIPT_PATH/profile_process_kill.sh disk_stress_duty_cycle.sh" &
    fi

    if [ $sendCpu -ne $zero ]
    then
      echo "Execute $Node1: pkill stress"
      ssh -i $FDT_PRIV_KEY $Node1 "pkill stress"
    fi

    if [ $recvIo -ne $zero ]
    then
      echo "Execute $Node1: kill recvIO processes"
      #ssh -i $FDT_PRIV_KEY $Node2 "$REMOTE_SCRIPT_PATH/profile_process_kill.sh disk_stress_duty_cycle.sh" &
    fi

    if [ $recvCpu -ne $zero ]
    then
      echo "Execute $Node2: pkill stress"
      ssh -i $FDT_PRIV_KEY $Node2 "pkill stress"
    fi

    #After the transfer ends immediately kill the iostat and sar processes
    echo "Killing the sar and iostat processes immediately"
    ssh -i $FDT_PRIV_KEY $Node1 "pkill sar"
    ssh -i $FDT_PRIV_KEY $Node1 "pkill iostat"
    ssh -i $FDT_PRIV_KEY $Node1 "sudo pkill iotop"
    #killing profile_process.sh is redundant as it uses the transfer_end flag
    ssh -i $FDT_PRIV_KEY $Node1 "$REMOTE_SCRIPT_PATH/profile_process_kill.sh profile_process.sh"
    ssh -i $FDT_PRIV_KEY $Node2 "pkill sar"
    ssh -i $FDT_PRIV_KEY $Node2 "pkill iostat"
    ssh -i $FDT_PRIV_KEY $Node2 "sudo pkill iotop"
    ssh -i $FDT_PRIV_KEY $Node2 "$REMOTE_SCRIPT_PATH/profile_process_kill.sh profile_process.sh"


    #Copy the logs to FDT
    scp -i $FDT_PRIV_KEY $Node1:$LOG_PATH_CLD/$LOG_SEND_grid $LOG_PATH_FDT
    scp -i $FDT_PRIV_KEY $Node1:$LOG_PATH_CLD/$LOG_SEND_iostat $LOG_PATH_FDT
    scp -i $FDT_PRIV_KEY $Node1:$LOG_PATH_CLD/$LOG_SEND_iotop $LOG_PATH_FDT
    scp -i $FDT_PRIV_KEY $Node1:$LOG_PATH_CLD/$LOG_SEND_sar $LOG_PATH_FDT
    scp -i $FDT_PRIV_KEY $Node1:$LOG_PATH_CLD/$LOG_SEND_process_cpu $LOG_PATH_FDT
    scp -i $FDT_PRIV_KEY $Node1:$LOG_PATH_CLD/$LOG_SEND_diskIO $LOG_PATH_FDT
    scp -i $FDT_PRIV_KEY $Node2:$LOG_PATH_CLD/$LOG_RECV_iostat $LOG_PATH_FDT
    scp -i $FDT_PRIV_KEY $Node2:$LOG_PATH_CLD/$LOG_RECV_iotop $LOG_PATH_FDT
    scp -i $FDT_PRIV_KEY $Node2:$LOG_PATH_CLD/$LOG_RECV_sar $LOG_PATH_FDT
    scp -i $FDT_PRIV_KEY $Node2:$LOG_PATH_CLD/$LOG_RECV_process_cpu $LOG_PATH_FDT
    scp -i $FDT_PRIV_KEY $Node2:$LOG_PATH_CLD/$LOG_RECV_diskIO $LOG_PATH_FDT

    echo "Delete the logs from the send and receive hosts"
    ssh -i $FDT_PRIV_KEY $Node1 "rm $LOG_PATH_CLD/*.txt"
    ssh -i $FDT_PRIV_KEY $Node2 "rm $LOG_PATH_CLD/*.txt"
    #Sleep between transfers for a little longer just so that the contending disk utilization process dies before the next transfer
    echo "Sleep for 200 seconds..."
    sleep 200
done
