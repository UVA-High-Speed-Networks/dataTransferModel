
transferFeatureFile=$1
LOG_PATH="/home/sm8kk/FDT-IDC-pS-Modelling/logs"
SCRIPT_PATH="/home/sm8kk/FDT-IDC-pS-Modelling/parsing-scripts"
N=3


echo "transfer,sendCpuUtil,sendDiskUtil,sendProcNum,sendTransferCpu,transferDiskRead,recvCpuUtil,recvDiskUtil,recvProcNum,recvTransferCpu,transferDiskWrite,dur,size,rate" > $transferFeatureFile
for i in `seq 1 $N`; do
    LOG_SEND_grid="grid_log_send_to_recv_transfer_"$i".txt"
    LOG_SEND_sar="sar_log_send_transfer_"$i".txt"
    LOG_SEND_proc="process_cpu_log_send_transfer_"$i".txt"
    LOG_SEND_iotop="iotop_log_send_transfer_"$i".txt"
    #LOG_SEND_ifconfig="ifconfig_log_ps_transfer_"$i".txt"
    LOG_RECV_sar="sar_log_recv_transfer_"$i".txt"
    LOG_RECV_proc="process_cpu_log_recv_transfer_"$i".txt"
    LOG_RECV_iotop="iotop_log_recv_transfer_"$i".txt"

    echo "Running $SCRIPT_PATH/parse-sar-cpu-util.sh $LOG_PATH/$LOG_SEND_sar"
    sendCpu=`$SCRIPT_PATH/parse-sar-cpu-util.sh $LOG_PATH/$LOG_SEND_sar`
    echo $sendCpu
    echo "Running $SCRIPT_PATH/parse-sar-disk-util.sh $LOG_PATH/$LOG_SEND_sar"
    sendDisk=`$SCRIPT_PATH/parse-sar-disk-util.sh $LOG_PATH/$LOG_SEND_sar`
    echo $sendDisk
    echo "Running $SCRIPT_PATH/parse-num-process.sh $LOG_PATH/$LOG_SEND_proc"
    sendProc=`$SCRIPT_PATH/parse-num-process.sh $LOG_PATH/$LOG_SEND_proc`
    echo $sendProc
    echo "Running $SCRIPT_PATH/parse-process-cpu-util.sh $LOG_PATH/$LOG_SEND_proc globus-url"
    sendTransfer=`$SCRIPT_PATH/parse-process-cpu-util.sh $LOG_PATH/$LOG_SEND_proc globus-url`
    echo $sendTransfer
    echo "Running $SCRIPT_PATH/parse-iotop-disk-speed-read.sh globus-url-copy $LOG_PATH/$LOG_SEND_iotop"
    readTransferDiskSpeed=`$SCRIPT_PATH/parse-iotop-disk-speed-read.sh globus-url-copy $LOG_PATH/$LOG_SEND_iotop`
    echo $readTransferDiskSpeed
    echo "Running $SCRIPT_PATH/parse-sar-cpu-util.sh $LOG_PATH/$LOG_RECV_sar"
    recvCpu=`$SCRIPT_PATH/parse-sar-cpu-util.sh $LOG_PATH/$LOG_RECV_sar`
    echo $recvCpu
    echo "Running $SCRIPT_PATH/parse-sar-disk-util.sh $LOG_PATH/$LOG_RECV_sar"
    recvDisk=`$SCRIPT_PATH/parse-sar-disk-util.sh $LOG_PATH/$LOG_RECV_sar`
    echo $recvDisk
    echo "Running $SCRIPT_PATH/parse-num-process.sh $LOG_PATH/$LOG_RECV_proc"
    recvProc=`$SCRIPT_PATH/parse-num-process.sh $LOG_PATH/$LOG_RECV_proc`
    echo $recvProc
    echo "Running $SCRIPT_PATH/parse-process-cpu-util-multi-proc.sh $LOG_PATH/$LOG_RECV_proc globus-gri"
    recvTransfer=`$SCRIPT_PATH/parse-process-cpu-util-multi-proc.sh $LOG_PATH/$LOG_RECV_proc globus-gri`
    echo $recvTransfer
    echo "Running $SCRIPT_PATH/parse-iotop-disk-speed-write.sh globus-gridftp-server $LOG_PATH/$LOG_RECV_iotop"
    writeTransferDiskSpeed=`$SCRIPT_PATH/parse-iotop-disk-speed-write.sh globus-gridftp-server $LOG_PATH/$LOG_RECV_iotop`
    echo $writeTransferDiskSpeed
    echo "Running $SCRIPT_PATH/parse-grid-client-log.sh $LOG_PATH/$LOG_SEND_grid"
    srd=`$SCRIPT_PATH/parse-grid-client-log.sh $LOG_PATH/$LOG_SEND_grid`
    echo $srd
    echo "$i,$sendCpu,$sendDisk,$sendProc,$sendTransfer,$readTransferDiskSpeed,$recvCpu,$recvDisk,$recvProc,$recvTransfer,$writeTransferDiskSpeed,$srd" >> $transferFeatureFile

done
