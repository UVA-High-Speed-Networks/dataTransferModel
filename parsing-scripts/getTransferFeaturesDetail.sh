
transferFeatureFile=$1
LOG_PATH="/home/sm8kk/FDT-IDC-pS-Modelling/logs-one-iperf-mem-mem-geni"
SCRIPT_PATH="/home/sm8kk/FDT-IDC-pS-Modelling/parsing-scripts"
N=91


echo "transfer,sendCpuUtil,sendDiskUtil,sendProcNum,sendTransferCpu,recvCpuUtil,recvDiskUtil,recvProcNum,recvTransferCpu,dur,size,rate" > $transferFeatureFile
for i in `seq 1 $N`; do
    LOG_SEND_iperf="iperf_log_send_to_recv_transfer_"$i".txt"
    LOG_SEND_sar="sar_log_send_transfer_"$i".txt"
    LOG_SEND_proc="process_cpu_log_send_transfer_"$i".txt"
    LOG_RECV_sar="sar_log_recv_transfer_"$i".txt"
    LOG_RECV_proc="process_cpu_log_recv_transfer_"$i".txt"

    echo "Running $SCRIPT_PATH/parse-sar-cpu-util.sh $LOG_PATH/$LOG_SEND_sar"
    sendCpu=`$SCRIPT_PATH/parse-sar-cpu-util.sh $LOG_PATH/$LOG_SEND_sar`
    echo $sendCpu
    echo "Running $SCRIPT_PATH/parse-sar-disk-util.sh $LOG_PATH/$LOG_SEND_sar"
    sendDisk=`$SCRIPT_PATH/parse-sar-disk-util.sh $LOG_PATH/$LOG_SEND_sar`
    echo $sendDisk
    echo "Running $SCRIPT_PATH/parse-num-process.sh $LOG_PATH/$LOG_SEND_proc"
    sendProc=`$SCRIPT_PATH/parse-num-process.sh $LOG_PATH/$LOG_SEND_proc`
    echo $sendProc
    echo "Running $SCRIPT_PATH/parse-process-cpu-util.sh $LOG_PATH/$LOG_SEND_proc"
    sendTransfer=`$SCRIPT_PATH/parse-process-cpu-util.sh $LOG_PATH/$LOG_SEND_proc`
    echo $sendTransfer
    echo "Running $SCRIPT_PATH/parse-sar-cpu-util.sh $LOG_PATH/$LOG_RECV_sar"
    recvCpu=`$SCRIPT_PATH/parse-sar-cpu-util.sh $LOG_PATH/$LOG_RECV_sar`
    echo $recvCpu
    echo "Running $SCRIPT_PATH/parse-sar-disk-util.sh $LOG_PATH/$LOG_RECV_sar"
    recvDisk=`$SCRIPT_PATH/parse-sar-disk-util.sh $LOG_PATH/$LOG_RECV_sar`
    echo $recvDisk
    echo "Running $SCRIPT_PATH/parse-num-process.sh $LOG_PATH/$LOG_RECV_proc"
    recvProc=`$SCRIPT_PATH/parse-num-process.sh $LOG_PATH/$LOG_RECV_proc`
    echo $recvProc
    echo "Running $SCRIPT_PATH/parse-process-cpu-util.sh $LOG_PATH/$LOG_RECV_proc"
    recvTransfer=`$SCRIPT_PATH/parse-process-cpu-util.sh $LOG_PATH/$LOG_RECV_proc`
    echo $recvTransfer
    echo "Running $SCRIPT_PATH/parse-iperf-log-disk.sh $LOG_PATH/$LOG_SEND_iperf"
    iperfDat=`$SCRIPT_PATH/parse-iperf-log-disk.sh $LOG_PATH/$LOG_SEND_iperf`
    echo $iperfDat
    echo "$i,$sendCpu,$sendDisk,$sendProc,$sendTransfer,$recvCpu,$recvDisk,$recvProc,$recvTransfer,$iperfDat" >> $transferFeatureFile

done
