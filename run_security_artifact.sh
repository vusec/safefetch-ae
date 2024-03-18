#!/bin/bash
. global_exports.sh
# First argument is a filename
[[ !  -z  $1  ]] || exit

execute_security_artifact () {
    # enter exploit dir
    cd exploit_cve_2016_6516

    mkdir -p ../playground/security/$1
    echo 'reproductions' > ../playground/security/$1/results.csv
    # Clean dmesg
    sudo dmesg -C
    for times in $(seq 1 $SECURITY_RUNS)
    do
        echo Run $times
        ./exploit 7 65534 1000000 0
        sudo rm -f /tmp/test.txt
        sudo rm -f /tmp/test2.txt
        # Dump the number of reproductions in the result file
        sudo dmesg | grep 'Bug-Warning' | wc -l >> ../playground/security/$1/results.csv
        # Clear dmesg
        sudo dmesg -C 
    done

    # Back to top
    cd ..
}

run_baseline_and_safefetch_configs () {
   # Get filename
   filename=config_list
   
   echo "Running security artifact on baseline..."
   # Run the artifact on the baseline config
   execute_security_artifact baseline


   echo "Running security artifact with safefetch enabled..."
   # Setup dfcacher hooks
   ./safefetch_control.sh -hooks

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
     echo "Preparing to switch to [${kernel_config}] safefetch config"
     sleep 1
     echo "Switching to this config..."
     ./safefetch_control.sh $kernel_config

     # Now execute the security artifact with safefetch enabled
     execute_security_artifact safefetch

     # Disable the defense and sleep for a bit.
     ./safefetch_control.sh 

     echo "Finished running config..."

   done
}

if [[ $1 == 'exploit' ]]; then
   # Build the POC for the CVE
   cd exploit_cve_2016_6516 && gcc doublefetch.c  -pthread -o exploit && cd ..
   run_baseline_and_safefetch_configs
   exit 0
else
   echo 'Cannot run security artifact on current kernel must be kernel 5.11.0-exploit+'
   exit 0
fi


