#!/bin/bash
. global_exports.sh

TIMES=1

echo "### LMBench benchmark"
echo ${RESULTS_DIR}
echo "We will do: "$TIMES runs

cd ${BENCHMARKS_DIR}/lmbench3 || ( echo "Run the install script before using lmbench"; exit 1 )
if [ ! -f "./bin/x86_64-linux-gnu/CONFIG.$(hostname)" ]; then
    echo "First build and configure lmbench by running 'make results' in the benchmark folder";
    exit 1
fi

rm -r results/x86_64-linux-gnu/*

tries=1
while [ $tries -le $TIMES ]
do
    echo "Benchmark number "${tries}
    make rerun
    ((tries++))
done

cd ../.. 
