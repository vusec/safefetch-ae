#!/bin/bash
. global_exports.sh

clean_all () {
    rm -rf tmp
    rm -rf safefetch
    rm -rf benchmarks
    rm -rf ~/.phoronix-test-suite
    sudo apt-get purge phoronix-test-suite
}

install_all () {
     clean_all

     echo "### Prepping installation..."
     mkdir -p tmp
     mkdir -p benchmarks
     sudo apt-get install libntirpc-dev flex bison libelf-dev libssl-dev bc build-essential libncurses-dev coreutils

     echo "### Cloning SafeFetch kernel..."
     git clone ${SAFEFETCH_REPO}
     echo "### Finished cloning Safefetch kernel..."

     # Install LMBench benchmarking suite
     echo "### Installing LMBench..."
     cd tmp || exit
     wget -q --no-check-certificate "https://downloads.sourceforge.net/project/lmbench/development/lmbench-3.0-a9/lmbench-3.0-a9.tgz"
     tar -xf lmbench-3.0-a9.tgz
     mv lmbench-3.0-a9 ../benchmarks/lmbench3
     rm lmbench-3.0-a9.tgz
     cd ../
     echo "### Finished installing LMBench..."

     echo "### Building LMBench..."
     cd ./benchmarks/lmbench3 || exit

     make -s build 2> lmbench_error.log
     errors=$(cat lmbench_error.log | grep Error| wc -l)
     rm lmbench_error.log

     if [ $errors -ne 0 ]; then
        echo "### Applying LMBench patch"
        patch -p1 < ../../patches/lmbench.patch
        make -s build 2> lmbench_error.log
        errors=$(cat lmbench_error.log | grep Error| wc -l)
        rm lmbench_error.log
        if [ $errors -ne 0 ]; then
            echo '### Failed to install LMBEnch (contact artifact owners)'
            exit 1
        fi
     else
        echo "### LMBench builds (no patch needed)"
     fi


     echo "### Configure LMBench..."
     pwd
     cd ./scripts || exit
     printf "1\n1\n512\nOS\nno\n\n\n\n\nno\n" | ./config-run

     cd ../../../ || exit
     ./configure_lmbench.sh

     echo "### LMBench installed!"



     # Install OSBench benchmarking suite
     echo "### Installing OSBench...";
     cd ./benchmarks || exit
     # dependencies
     sudo apt-get install meson ninja-build
     # benchmark
     git clone https://github.com/mbitsnbites/osbench.git;

     cd osbench || exit;
     mkdir -p out;

     cd out || exit;
     echo "### Building OSBench..."
     meson --buildtype=release ../src
     ninja
     cd ../../../ || exit

     echo "### OSBench installed!"

     echo "### Installing phoronix benchmarking suite..."
     cd tmp || exit


     # dependencies
     sudo apt-get install php-cli php-xml

     wget -q --no-check-certificate "https://phoronix-test-suite.com/releases/repo/pts.debian/files/phoronix-test-suite_10.8.4_all.deb"
     sudo dpkg -i ./phoronix-test-suite_10.8.4_all.deb
     rm phoronix-test-suite_10.8.4_all.deb
     cd ../

     echo "### Installing phoronix required benchmarks..."
     phoronix-test-suite install system/openssl
     phoronix-test-suite install pts/pybench
     phoronix-test-suite install pts/git
     phoronix-test-suite install pts/apache
     phoronix-test-suite install pts/nginx
     phoronix-test-suite install pts/redis
     phoronix-test-suite install pts/ipc-benchmark

     echo "### Configuring phoronix benchmarks..."
     printf "y\nn\nn\ny\nn\ny\nn\n" | phoronix-test-suite batch-setup

     echo "### Phoronix benchmarking suite installed!"

     echo '### Installing paper-results'

     cd patches
     cp -r phoronix/. ~/.phoronix-test-suite/test-results/.
     cd ..

     echo '### Finished installing paper-results'

     echo "### Installing result aggregation and representation dependencies..."
     # jpeg necessary for matplotlib
     sudo apt install libjpeg-dev zlib1g-dev 
     pip3 install numpy matplotlib

     echo '### Install pdflatex'
     sudo apt-get install texlive-latex-base texlive-fonts-extra texlive-fonts-recommended texlive-bibtex-extra biber

     cd tmp || exit
     git clone git@github.com:wpengfei/CVE-2016-6516-exploit.git
     cp -r './CVE-2016-6516-exploit/Scott Bauer' ./exploit_cve_2016_6516
     mv ./exploit_cve_2016_6516 ../exploit_cve_2016_6516
     rm -rf ./CVE-2016-6516-exploit

     echo "### CVE-2016-6516 exploit installed!"

     cd .. && rm -rf tmp

     echo "### Installation complete!"

     echo 0
}


install_all