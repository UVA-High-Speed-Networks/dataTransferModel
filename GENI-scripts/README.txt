Transfer tests that also collects sar and iostat logs:


1. transfer_input_param-disk-to-disk.sh: Runs disk to disk transfers between two GENI nodes (Node1 ---> Node2), using iperf3 1 stream. Input parameters are taken from a csv file to extract the transfer num, sendCpu load, sendDisk load, recvCpu load, recvDisk load. It collects sar, iostat, and top logs for the entire duration of the transfer. The external load for the disk i.e., sendDisk and recvDisk is not implemented. The orchestration of the data transfer, log collection, running contenting stress jobs is run from our FDT server. The logs generated at Node1 and Node2 are copied back to FDT. 
Helper scripts: profile_process.sh, profile_process_kill.sh


2. transfer_input_param-mem-mem.sh: Same as that of (1) but its executes memory to memory transfers.

3. transfer_input_param_CPU_disk_cloudlab.sh: This is a newest and advanced script. It runs disk to disk transfers between two cloudlab hosts (Node1 ---> Node2). The script is again run from FDT like in (1 and 2). Input parameters are taken from a csv file to extract the transfer num, sendCpu load, sendDisk load, recvCpu load, recvDisk load. It collects sar, iostat, and top logs for the entire duration of the transfer. All the input parameters that adds external load are implemented in this script. 
The logs generated are copied back to FDT.
Additional helper scripts: disk_stress_duty_cycle.sh, sleepTime.py
Usage: ./transfer_input_param_CPU_disk_cloudlab.sh input-param-cloudlab.csv > three-transfers-log.txt

Helper scripts:
profile_process.sh: profile a particular process for its CPU usage and track the number of running processes
profile_process_kill.sh: Kills the profiler process


Input parameters:

transfer num: The transfer number. It must be unique.

sendCpu: Number of "stress -c" processes to be executed at the sender.

sendDisk: Percentage of time within a 10 second interval a separate disk write process runs. Example if it is 70, then in an interval of 10 seconds a write process writes to the disk for 7 seconds and sleeps for 3 seconds. This operation of disk write and sleep within 10 seconds is periodically repeated throughout the duration of the transfer. This is executed at the sender.

recvCpu: similar to sendCpu but executed at the receiver.

recvDisk: similar to sendDisk but executed at the receiver.
