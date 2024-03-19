#!/bin/bash

# Check whether we have the CVE POC source code installed
[ ! -f ./exploit_cve_2016_6516/doublefetch.c ] && exit 1

# Check whether we have configured lmbench
[ ! -f ./benchmarks/lmbench3/bin/x86_64-linux-gnu/CONFIG.$(hostname) ] && exit 2

# Check whether we have all osbench binaries
[ ! -f ./benchmarks/osbench/out/create_files] && exit 3
[ ! -f ./benchmarks/osbench/out/create_processes] && exit 3
[ ! -f ./benchmarks/osbench/out/create_threads] && exit 3
[ ! -f ./benchmarks/osbench/out/launch_programs] && exit 3
[ ! -f ./benchmarks/osbench/out/mem_alloc] && exit 3

# Check wheather we have installed phoronix workspace
[ ! -d ~/.phoronix-test-suite/ ] && exit 4
[ ! -d ~/.phoronix-test-suite/test-results/baseline-paper ] && exit 4
[ ! -d ~/.phoronix-test-suite/test-results/whitelist-paper ] && exit 4
[ ! -d ~/.phoronix-test-suite/test-results/safefetch-paper ] && exit 4
[ ! -d ~/.phoronix-test-suite/test-results/midas-paper ] && exit 4

