#!/bin/bash

root_dir=~/.phoronix-test-suite/test-results
#root_dir="."

#IPC_benchmark - Type: TCP Socket - Message Bytes: 128 (Messages\/sec)"
#Redis - Test: GET - Parallel Connections: 50 (Reqs/sec)
#Redis - Test: SET - Parallel Connections: 50 (Reqs/sec)
#PyBench - Total For Average Test Times (Milliseconds)
#nginx - Connections: 100 (Reqs/sec)
#Apache HTTP Server - Concurrent Requests: 100 (Reqs/sec)
#Git - Time To Complete Common Git Commands (sec)
#Timed Linux Kernel Compilation - Build: defconfig (sec)
#OpenSSL - Algorithm: SHA512 (byte/s)
mkdir -p phoronix
for f in $(ls ${root_dir})
do
  echo "Processing $f file..."
  phoronix-test-suite result-file-to-csv $f > /dev/null 2>&1
  phoronix-test-suite result-file-raw-to-csv $f > /dev/null 2>&1
  mkdir -p ./phoronix/$f
  echo "# phoronix benchmarking results" > ./phoronix/$f/results.csv
  echo "bench;info;avg_rounded;avg;med;stddev;lowest;highest;cv" >> ./phoronix/$f/results.csv
  cat $HOME/$f.csv | grep IPC -A 7 | sed  's/\"IPC_benchmark - Type: TCP Socket - Message Bytes: 128 (Messages\/sec)\"/IPC/g' | sed  's/\"Redis - Test: GET - Parallel Connections: 50 (Reqs\/sec)\"/Redis-G/g'  | sed  's/\"Redis - Test: SET - Parallel Connections: 50 (Reqs\/sec)\"/Redis-S/g' | sed  's/\"PyBench - Total For Average Test Times (Milliseconds)\"/pybench/g' | sed  's/\"nginx - Connections: 100 (Reqs\/sec)\"/nginx/g' | sed  's/\"Apache HTTP Server - Concurrent Requests: 100 (Reqs\/sec)\"/apache/g' | sed  's/\"Git - Time To Complete Common Git Commands (sec)\"/git/g' | sed  's/\"Timed Linux Kernel Compilation - Build: defconfig (sec)\"/linux/g' | sed  's/\"OpenSSL - Algorithm: SHA512 (byte\/s)\"/openssl/g' |  sed  's/,/\;/g' >> intermediary
  cat intermediary | grep IPC | tr '\n' ';' >> ./phoronix/$f/results.csv
  cat $HOME/$f-raw.csv | grep -A 3 IPC | tail -1 | python3 phoronix_process.py >> ./phoronix/$f/results.csv
  cat intermediary | grep openssl | tr '\n' ';' >> ./phoronix/$f/results.csv 
  cat $HOME/$f-raw.csv | grep -A 3 OpenSSL | tail -1 | python3 phoronix_process.py  >> ./phoronix/$f/results.csv
  cat intermediary | grep Redis-G | tr '\n' ';' >> ./phoronix/$f/results.csv 
  cat $HOME/$f-raw.csv | grep -A 3 Redis | grep -A 3 GET  | tail -1 | python3 phoronix_process.py  >> ./phoronix/$f/results.csv
  cat intermediary | grep Redis-S | tr '\n' ';' >> ./phoronix/$f/results.csv 
  cat $HOME/$f-raw.csv | grep -A 3 Redis | grep -A 3 SET  | tail -1 | python3 phoronix_process.py  >> ./phoronix/$f/results.csv
  cat intermediary | grep pybench | tr '\n' ';' >> ./phoronix/$f/results.csv 
  cat $HOME/$f-raw.csv | grep -A 3 PyBench  | tail -1 | python3 phoronix_process.py  >> ./phoronix/$f/results.csv
  cat intermediary | grep nginx | tr '\n' ';' >> ./phoronix/$f/results.csv 
  cat $HOME/$f-raw.csv | grep -A 3 nginx  | tail -1 | python3 phoronix_process.py  >> ./phoronix/$f/results.csv
  cat intermediary | grep apache | tr '\n' ';' >> ./phoronix/$f/results.csv 
  cat $HOME/$f-raw.csv | grep -A 3 Apache | tail -1 | python3 phoronix_process.py  >> ./phoronix/$f/results.csv
  cat intermediary | grep git | tr '\n' ';' >> ./phoronix/$f/results.csv 
  cat $HOME/$f-raw.csv | grep -A 3 Git | tail -1 | python3 phoronix_process.py   >> ./phoronix/$f/results.csv
  rm intermediary
  rm $HOME/$f*.csv


done
