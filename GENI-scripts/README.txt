Transfer tests that also collects sar and iostat logs:

1. transfer-simple-num-runs.sh: Runs data transfer experiment for a given number of test

2. transfer_input_param-disk-to-disk.sh: Runs disk to disk transfers between two GENI nodes (Node1 ---> Node2), using iperf3 1 stream. Input parameters are taken from a csv file to extract the transfer num, sendCpu load, sendDisk load, recvCpu load, recvDisk load. It collects sar, iostat, and top logs for the entire duration of the transfer. The external load for the disk i.e., sendDisk and recvDisk is not implemented. The orchestration of the data transfer, log collection, running contenting stress jobs is run from our FDT server.


transfer_input_param-mem-mem.sh: For memory to memory transfers.
profile_process.sh: profile a particular process for its CPU usage and track the number of running processes
profile_process_kill.sh: Kills the profiler process
