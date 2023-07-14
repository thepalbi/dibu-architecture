#!/usr/bin/env bash
set -eufo pipefail

# tests=$(find . -name "test_*.py")
tests="./test_datapath.py"

for test in $tests; do
    echo "RUNNING TEST MODULE: $test"
    module=`echo $test|sed -E 's/\.\/(.+)\.py/\1/g'`

    echo "cleaning"
    MODULE=$module make clean

    if [ "${TESTS:-}" != "" ]; then
        echo "running single test: $TESTS"
        TESTS=$TESTS MODULE=$module make regression
    else
        unset TESTS
        MODULE=$module make regression
    fi
done
