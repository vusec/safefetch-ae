#!/bin/bash
SOURCE="${BASH_SOURCE[0]}"
export WD=$(dirname $SOURCE)
export RESULTS_DIR=playground/performance
export BENCHMARKS_DIR=benchmarks
export KERNEL_VERSION=5.11.0
export KERNEL_DIR=safefetch
[ -z "$RUNS" ] && export RUNS=11
export FORCE_TIMES_TO_RUN=$RUNS
export SECURITY_RUNS=5
export SAFEFETCH_REPO=git@github.com:vusec/safefetch.git
export MIDAS_REPO=https://github.com/HexHive/midas.git
