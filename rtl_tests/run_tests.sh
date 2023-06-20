#!/usr/bin/env bash
set -eufo pipefail

# tests=$(find . -name "test_*.py")
tests="./test_datapath.py"

for test in $tests; do
    echo "RUNNING TEST MODULE: $test"
    module=`echo $test|sed -E 's/\.\/(.+)\.py/\1/g'`
    MODULE=$module make regression
done
