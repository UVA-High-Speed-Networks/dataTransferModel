
transferFeatureFile=$1
LOG_PATH="/home/sm8kk/FDT-IDC-pS-Modelling/logs-one-iperf-no-load-IDC-to-FDT"
SCRIPT_PATH="/home/sm8kk/FDT-IDC-pS-Modelling/parsing-scripts"
N=20


echo "transfer,sendCpuUtil,sendDiskUtil,recvCpuUtil,recvDiskUtil,dur,size,rate" > $transferFeatureFile
for i in `seq 1 $N`; do
    LOG_IDC_iperf="iperf_log_IDC_to_fdt_uva_transfer_"$i".txt"
    LOG_IDC_sar="sar_log_IDC_transfer_"$i".txt"
    LOG_FDT_sar="sar_log_FDT_transfer_"$i".txt"

    echo "Running $SCRIPT_PATH/parse-sar-cpu-util.sh $LOG_PATH/$LOG_IDC_sar"
    sendCpu=`$SCRIPT_PATH/parse-sar-cpu-util.sh $LOG_PATH/$LOG_IDC_sar`
    echo $sendCpu
    echo "Running $SCRIPT_PATH/parse-sar-disk-util.sh $LOG_PATH/$LOG_IDC_sar"
    sendDisk=`$SCRIPT_PATH/parse-sar-disk-util.sh $LOG_PATH/$LOG_IDC_sar`
    echo $sendDisk
    echo "Running $SCRIPT_PATH/parse-sar-cpu-util.sh $LOG_PATH/$LOG_FDT_sar"
    recvCpu=`$SCRIPT_PATH/parse-sar-cpu-util.sh $LOG_PATH/$LOG_FDT_sar`
    echo $recvCpu
    echo "Running $SCRIPT_PATH/parse-sar-disk-util.sh $LOG_PATH/$LOG_FDT_sar"
    recvDisk=`$SCRIPT_PATH/parse-sar-disk-util.sh $LOG_PATH/$LOG_FDT_sar`
    echo $recvDisk
    echo "Running $SCRIPT_PATH/parse-iperf-log-disk.sh $LOG_PATH/$LOG_IDC_iperf"
    iperfDat=`$SCRIPT_PATH/parse-iperf-log-disk.sh $LOG_PATH/$LOG_IDC_iperf`
    echo $iperfDat
    echo "$i,$sendCpu,$sendDisk,$recvCpu,$recvDisk,$iperfDat" >> $transferFeatureFile

done
