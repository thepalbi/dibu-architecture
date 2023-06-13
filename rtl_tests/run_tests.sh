#!/usr/bin/env bash
set -eufo pipefail

COMPILE_ARGS="-Wall -I `pwd`/../rtl"

function run_test {
    [ -d "sim_build" ] && echo "cleaning previous sim" && make clean
    read -a source_files <<< "$1"
    fully_qualified_source_files=""
    for sf in "${source_files[@]}"; do
        fully_qualified_source_files+=$(echo "`pwd`/../rtl/$sf ")
    done

    VERILOG_SOURCES=$fully_qualified_source_files \
    TOPLEVEL=$2 \
    COMPILE_ARGS=$COMPILE_ARGS \
    MODULE=$3 make
}

# echo "running alu tests"
# run_test "`pwd`/../rtl/alu.v" alu test_alu

# echo "running memory tests"
# run_test "`pwd`/../rtl/tb_memory.v `pwd`/../rtl/memory.v" tb_memory test_memory_bank

# echo "running register bank tests"
# run_test "`pwd`/../rtl/register_bank.v" register_bank test_register_bank

# echo "running alu register machine tests"
# run_test \
#     "`pwd`/../rtl/register_bank.v `pwd`/../rtl/alu.v `pwd`/../rtl/register_alu_machine.v" \
#     register_alu_machine \
#     test_register_alu_machine

echo "running simple datapath tests"
run_test \
    "datapath.v pc.v register.v memory.v control_unit.v register_bank.v alu.v" \
    datapath \
    test_datapath
