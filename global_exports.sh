#!/bin/bash
SOURCE="${BASH_SOURCE[0]}"
export WD=$(dirname $SOURCE)
export RESULTS_DIR=playground/performance
export BENCHMARKS_DIR=benchmarks
export KERNEL_VERSION=5.11.0
export KERNEL_DIR=safefetch
[ -z "$RUNS" ] && export RUNS=11
export FORCE_TIMES_TO_RUN=$RUNS
