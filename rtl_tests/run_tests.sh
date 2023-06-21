#!/usr/bin/env bash
set -eufo pipefail

# tests=$(find . -name "test_*.py")
tests="./test_datapath.py"

if [[ "$#" == "1" ]]; then
    TESTS=$1
fi


for test in $tests; do
    echo "RUNNING TEST MODULE: $test"
    module=`echo $test|sed -E 's/\.\/(.+)\.py/\1/g'`
    if [ "${TESTS:-}" != "" ]; then
        echo "running single test: $TESTS"
        TESTS=$TESTS MODULE=$module make regression
    else
        MODULE=$module make regression
    fi
done
