Scripts to run WAN data transfer experiments between hosts at UVa to FDT server at Wisconsin

scp-gridftp-transfer-FDT-IDC-UVa-FDT-Wisc.sh:
The script performs scp transfers and gridFTP transfers with 4 streams. Each stream is supposed to send a 5 GB file.

scp between FDT UVa is burdened with a CPU intensive activity with "stress -c 100" while the transfer goes on. Basically
send side is CPU constrained and its performance is low compared to IDC server even with its low disk write speeds.
FDT UVa -> FDT Wisc
IDC UVa -> FDT Wisc

Role changed where CPU is stressed at the receive FDT UVa side again with "stress -c 100". Here a 4 stream gridFTP transfer is run.
FDT Wisc --> FDT UVa

transfer-streams-iperf-4-FDT-wisc-to-FDT-IDC-UVa.sh:
The script executes iperf of 40 transfers from with 4 streams. Each stream is supposed to send a 3 GB file.
FDT wisc -> FDT Uva
FDT wisc -> IDC Uva
