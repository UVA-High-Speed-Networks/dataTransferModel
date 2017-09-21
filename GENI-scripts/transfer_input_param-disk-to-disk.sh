#Transfers file from Node1 --> Node2, using iperf3 1 stream

#cd /home/uvauser/sm8kk
#file="10_GB_file.txt"
paramFile=$1
wc_out=$(wc -l $paramFile)
length=($wc_out)
file="4_GB_file.txt"
FDT_UVa="fdt-uva.dynes.virginia.edu"
IDC_UVa="idc-uva.dynes.virginia.edu"
#LOG_PATH_IDC="/home/sm8kk/FDT-IDC-pS-Modelling/logs"
LOG_PATH_FDT="/home/sm8kk/FDT-IDC-pS-Modelling/logs"
LOG_PATH_GENI="/users/sm8kk/logs"
FDT_PRIV_KEY="*********"

FDT_MGMT_IP="**********"
IDC_MGMT_IP="**********"
Node1="sm8kk@pc322.emulab.net"
Node3="sm8kk@pc346.emulab.net"
Node2="sm8kk@pc331.emulab.net"
NODE1_IP="10.10.1.1"
NODE2_IP="10.10.1.2"
NODE3_IP="10.10.1.3"
zero=0
tmax=300 #5GB at min 1000bps speed takes 40 seconds
#tmax=120 #2 min iperf transfer
transfer=1
transferProcessApp="iperf"

#collecting rates from 40 such transfers
#while read line
#do
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

    LOG_SEND_iperf="iperf_log_send_to_recv_transfer_"$transfer".txt"
    LOG_SEND_iostat="iostat_log_send_transfer_"$transfer".txt"
    LOG_SEND_sar="sar_log_send_transfer_"$transfer".txt"
    LOG_SEND_process_cpu="process_cpu_log_send_transfer_"$transfer".txt"
    LOG_RECV_iostat="iostat_log_recv_transfer_"$transfer".txt"
    LOG_RECV_sar="sar_log_recv_transfer_"$transfer".txt"
    LOG_RECV_process_cpu="process_cpu_log_recv_transfer_"$transfer".txt"

    #log into the send node and start the cache flush process
    echo "ssh -i $FDT_PRIV_KEY $Node1 to run: sync"
    ssh -i $FDT_PRIV_KEY $Node1 "sync" #sync to disk
    #write a large GB file, which is as much as the memory of the RAM
    echo "Writing a 2 GB file to flush out the RAM.."
    ssh -i $FDT_PRIV_KEY $Node1 "dd if=/dev/zero of=2_GB_file_flush bs=1M count=2048 > /dev/null 2>&1"
    ssh -i $FDT_PRIV_KEY $Node1 "sync" #sync to disk

    echo "Starting the logging for CPU, Disk, and Network Utilization using sar and iostat as background processes.."
    echo "Also start collecting CPU usage and num of processes time series.."
    echo "ssh -i $FDT_PRIV_KEY $Node1 to run: iostat, sar, profiler"
    ssh -i $FDT_PRIV_KEY $Node1 "iostat -x 1 > $LOG_PATH_GENI/$LOG_SEND_iostat" &
    ssh -i $FDT_PRIV_KEY $Node1 "sar -u -d -n DEV 1 $tmax > $LOG_PATH_GENI/$LOG_SEND_sar" &
    ssh -i $FDT_PRIV_KEY $Node1 "/users/sm8kk/profile_process.sh $transferProcessApp > $LOG_PATH_GENI/$LOG_SEND_process_cpu" &
    
    echo "ssh -i $FDT_PRIV_KEY $Node2 to run: iostat, sar, profiler"
    ssh -i $FDT_PRIV_KEY $Node2 "iostat -x 1 > $LOG_PATH_GENI/$LOG_RECV_iostat" &
    ssh -i $FDT_PRIV_KEY $Node2 "sar -u -d -n DEV 1 $tmax > $LOG_PATH_GENI/$LOG_RECV_sar" &
    ssh -i $FDT_PRIV_KEY $Node2 "/users/sm8kk/profile_process.sh $transferProcessApp > $LOG_PATH_GENI/$LOG_RECV_process_cpu" &

    echo "Stress CPU and IO at the send host based on the input parameters"
    if [ $sendCpu -ne $zero ]
    then
      echo "Execute $Node1: stress -c $sendCpu"
      ssh -i $FDT_PRIV_KEY $Node1 "stress -c $sendCpu" &
    fi

    echo "Stress CPU and IO at the receive host based on the input parameters"
    if [ $recvCpu -ne $zero ]
    then
      echo "Execute $Node1: stress -c $recvCpu"
      ssh -i $FDT_PRIV_KEY $Node2 "stress -c $recvCpu" &
    fi

    echo "Start transfer DISK to DISK: $transfer"
    echo "Running at send node: iperf3 -c $NODE2_IP -i 1 -t $tmax -F $file"
    #this is a blocking call
    ssh -i $FDT_PRIV_KEY $Node1 "iperf3 -c $NODE2_IP -i 1 -t $tmax -F $file >> $LOG_PATH_GENI/$LOG_SEND_iperf"
    echo "End transfer: $transfer"

    #kill the CPU and IO loads
    echo "Killing all stress utility from send and receive nodes"
    if [ $sendCpu -ne $zero ]
    then
      echo "Execute $Node1: pkill stress"
      ssh -i $FDT_PRIV_KEY $Node1 "pkill stress"
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
    ssh -i $FDT_PRIV_KEY $Node1 "/users/sm8kk/profile_process_kill.sh"
    ssh -i $FDT_PRIV_KEY $Node2 "pkill sar"
    ssh -i $FDT_PRIV_KEY $Node2 "pkill iostat"
    ssh -i $FDT_PRIV_KEY $Node2 "/users/sm8kk/profile_process_kill.sh"


    #Copy the logs to FDT
    scp -i $FDT_PRIV_KEY $Node1:$LOG_PATH_GENI/$LOG_SEND_iperf $LOG_PATH_FDT
    scp -i $FDT_PRIV_KEY $Node1:$LOG_PATH_GENI/$LOG_SEND_iostat $LOG_PATH_FDT
    scp -i $FDT_PRIV_KEY $Node1:$LOG_PATH_GENI/$LOG_SEND_sar $LOG_PATH_FDT
    scp -i $FDT_PRIV_KEY $Node1:$LOG_PATH_GENI/$LOG_SEND_process_cpu $LOG_PATH_FDT
    scp -i $FDT_PRIV_KEY $Node2:$LOG_PATH_GENI/$LOG_RECV_iostat $LOG_PATH_FDT
    scp -i $FDT_PRIV_KEY $Node2:$LOG_PATH_GENI/$LOG_RECV_sar $LOG_PATH_FDT
    scp -i $FDT_PRIV_KEY $Node2:$LOG_PATH_GENI/$LOG_RECV_process_cpu $LOG_PATH_FDT

    echo "Delete the logs from the send and receive hosts"
    ssh -i $FDT_PRIV_KEY $Node1 "rm $LOG_PATH_GENI/*.txt"
    ssh -i $FDT_PRIV_KEY $Node2 "rm $LOG_PATH_GENI/*.txt"
    echo "Sleep for 2 seconds..."
    sleep 2
done
