#!/bin/bash
. global_exports.sh

[[ !  -z  $1  ]] && echo Supplied folder $1 || exit

TIMES=$FORCE_TIMES_TO_RUN

echo "### Phoronix benchmark"
echo "We will do: " $TIMES runs

cd ~/.phoronix-test-suite || ( echo "Run the install script before using phoronix"; exit 1 )

echo "Skipping phoronix kernel compilation test..."
printf "3\n3\n3\n1,2\n1\n4\n1\n$1\n$1\n" | phoronix-test-suite batch-run openssl pybench git apache nginx redis ipc-benchmark

