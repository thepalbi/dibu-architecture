#!/usr/bin/env bash
set -eufo pipefail

COMPILE_ARGS="-I `pwd`/../rtl"

function run_test {
    [ -d "sim_build" ] && echo "cleaning previous sim" && make clean

    VERILOG_SOURCES=$1 \
    TOPLEVEL=$2 \
    COMPILE_ARGS=$COMPILE_ARGS \
    MODULE=$3 make
}

echo "running memory tests"
run_test "`pwd`/../rtl/tb_memory.v `pwd`/../rtl/memory.v" tb_memory test_memory_bank

echo "running register bank tests"
run_test "`pwd`/../rtl/register_bank.v" register_bank test_register_bank

echo "running alu register machine tests"
run_test "`pwd`/../rtl/register_bank.v `pwd`/../rtl/alu.v `pwd`/../rtl/register_alu_machine.v" register_alu_machine test_register_alu_machine
