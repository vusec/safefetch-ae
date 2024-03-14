#!/bin/bash
. global_exports.sh

[[ !  -z  $1  ]] && echo Supplied folder $1 || exit

TIMES=$RUNS

echo "### LMBench benchmark"
echo ${RESULTS_DIR}
echo "We will do: "$TIMES runs

cd ${BENCHMARKS_DIR}/lmbench3 || ( echo "Run the install script before using lmbench"; exit 1 )
if [ ! -f "./bin/x86_64-linux-gnu/CONFIG.$(hostname)" ]; then
    echo "First build and configure lmbench by running 'make results' in the benchmark folder";
    exit 1
fi

rm -r results/x86_64-linux-gnu/*

#cat bin/x86_64-linux-gnu/CONFIG.$(hostname) | awk '{if ($1 ~ "ENOUGH" ) {print "ENOUGH=5000";next;};if ($1 ~ "MB=") {print "MB=1024";next;};if ($1 ~ "BENCHMARK_HARDWARE=") {print "BENCHMARK_HARDWARE=NO";next;};if ($1 ~ "BENCHMARK_OS=") {print "BENCHMARK_OS=YES";next;};if ($1 ~ /^BENCHMARK/) {sub(/=[[:print:]]*$/,"=");print $0;next;}; {print $0}}' > bin/x86_64-linux-gnu/temp.conf
#cat bin/x86_64-linux-gnu/temp.conf > bin/x86_64-linux-gnu/CONFIG.$(hostname)
tries=1
while [ $tries -le $TIMES ]
do
    echo "Benchmark number "${tries}
    make rerun
    ((tries++))
done

[ ! -d ../../${RESULTS_DIR}/lmbench/$1 ] && mkdir -p ../../${RESULTS_DIR}/lmbench/$1


counter=0
tries=1
while [ $tries -le $TIMES ]
do
    echo "Copying benchmark number "${counter}
    (set -x ; cp results/x86_64-linux-gnu/$(hostname).${counter} ../../${RESULTS_DIR}/lmbench/$1/LMBench.${counter} )
    ((counter++))
    ((tries++))
done

cd ../.. 
