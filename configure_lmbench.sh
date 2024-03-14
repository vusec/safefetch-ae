#!/bin/sh

cd ./benchmarks/lmbench3 || ( echo "Run the install script before configuring lmbench"; exit )
cd ./bin/x86_64-linux-gnu || ( echo "First build the required benchmarkings scripts by running 'make build'"; exit )
if [ ! -f "./CONFIG.$(hostname)" ]; then
    echo "First configure lmbench by running 'make results'";
    exit
fi


echo "### Configuring lmbench3..."

sed -i 's/ENOUGH=[[:digit:]]\+/ENOUGH=5000/' ./CONFIG.$(hostname)
sed -i 's/BENCHMARK_OS=YES/BENCHMARK_OS=YES/' ./CONFIG.$(hostname)
sed -i 's/BENCHMARK_SYSCALL=/BENCHMARK_SYSCALL=YES/' ./CONFIG.$(hostname)
sed -i 's/BENCHMARK_SELECT=/BENCHMARK_SELECT=YES/' ./CONFIG.$(hostname)
sed -i 's/BENCHMARK_SIG=/BENCHMARK_SIG=YES/' ./CONFIG.$(hostname)
sed -i 's/BENCHMARK_PROC=/BENCHMARK_PROC=YES/' ./CONFIG.$(hostname)
sed -i 's/BENCHMARK_PAGEFAULT=/BENCHMARK_PAGEFAULT=YES/' ./CONFIG.$(hostname)
sed -i 's/BENCHMARK_PIPE=/BENCHMARK_PIPE=YES/' ./CONFIG.$(hostname)
sed -i 's/BENCHMARK_UNIX=/BENCHMARK_UNIX=YES/' ./CONFIG.$(hostname)

sed -i 's/BENCHMARK_HARDWARE=YES/BENCHMARK_HARDWARE=NO/' ./CONFIG.$(hostname)
sed -i 's/MAIL=yes/MAIL=NO/' ./CONFIG.$(hostname)


echo "### Configuring complete!"
