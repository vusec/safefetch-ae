#!/bin/bash

# First argument is a filename
[[ !  -z  $1  ]] || exit
time_long_sleep=20
benchmark_config="all_bench"

run_baseline_and_safefetch_configs () {
   # Get filename
   filename=config_list

   make $benchmark_config BUILD_STRING=baseline

   # Setup dfcacher hooks
   ./dfcacher_control.sh -hooks

   # Read in the number of lines in the file
   num_lines=`wc -l $filename| awk '{print $1}'`

   # Would be nice to simply use the read command but in my case it fails
   for ln in $(seq 1 $num_lines)
   do
      # Get config at line ln
     line=`cat $filename| head -${ln} | tail -1`

      # If line is empty then continue
     [[ -z $line ]] && continue

     # Parse config and benchmark name
     benchmark_name=$(echo $line | awk '{ print $1}')
     kernel_config=$(echo $line | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}' | tr -d '"')

     # If config starts with a dash then move past this config
     [[ $benchmark_name = \#* ]] && continue

   
     # Switch to the new config.
     echo "Preparing to run [${kernel_config}] and save it to $benchmark_name"
     sleep 1
     echo "Switching to this config..."
     ./dfcacher_control.sh $kernel_config

     # Now execute the benchmarks
     make $benchmark_config BUILD_STRING=$benchmark_name

     # Disable the defense and sleep for a bit.

     echo "Sleeping..."
     ./dfcacher_control.sh 

     sleep ${time_long_sleep}

     echo "Continuing... WD --> `pwd`"

   done
   echo 0
}

if [ $1 = "safefetch" ]; then
   run_baseline_and_safefetch_configs
else
   make $benchmark_config BUILD_STRING=$1
fi

