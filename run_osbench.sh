#!/bin/bash
. global_exports.sh

[[ !  -z  $1  ]] && echo Supplied folder $1 || exit

TIMES=$RUNS

echo "### OSBench benchmark"
echo ${RESULTS_DIR}
echo "We will do: "$TIMES runs

mkdir -p ./${RESULTS_DIR}/osbench/$1

cd ${BENCHMARKS_DIR}/osbench || ( echo "Run the install script before using lmbench"; exit 1 )
if [ ! -f "./out/create_threads" ]; then
    echo "First build OSBench by running the installation script";
    exit 1
fi

mkdir -p ./create_files_rootdir

tries=1
while [ $tries -le $TIMES ]
do
    echo "Benchmark number "${tries};
    ./out/create_threads > ../../${RESULTS_DIR}/osbench/$1/OSBench.${tries};
    ./out/create_processes >> ../../${RESULTS_DIR}/osbench/$1/OSBench.${tries};
    ./out/launch_programs >> ../../${RESULTS_DIR}/osbench/$1/OSBench.${tries};
    ./out/create_files ./create_files_rootdir >> ../../${RESULTS_DIR}/osbench/$1/OSBench.${tries};
    ./out/mem_alloc >> ../../${RESULTS_DIR}/osbench/$1/OSBench.${tries};
    ((tries++))
done

cd ../..
