from os import path
import cocotb
from cocotb.triggers import Timer, FallingEdge, RisingEdge, ClockCycles
from cocotb.clock import Clock
from cocotb.binary import BinaryValue
import sys

CURRENT_DIR = path.dirname(path.realpath(__file__))
sys.path.append(path.join(CURRENT_DIR, "../"))

from dibuparser import parse, assemble

test_program = """mov r3 0xf0
not r4 r3
halt 
"""

test_compiled_program = assemble(parse(test_program))

print(test_compiled_program)

@cocotb.test()
async def datapath_simple_test(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.run.value = 0
    dut.code_w_en.value = 0

    # wait a bit, 2 clk cycles
    await Timer(20, units="ns")
    await FallingEdge(dut.clk)

    # write program
    dut.code_w_en.value = 1
    for i, l in enumerate(test_compiled_program.splitlines(keepends=False)):
        dut.code_addr_in.value = i
        dut.code_in.value = BinaryValue(l)
        await FallingEdge(dut.clk)

    # im in a falling edge, and code has been written

    dut.code_w_en.value = 0
    dut.run.value = 1

    dut._log.info("arranco a ejecutar")

    # memory has been written
    #await wait_until_diff_ir(dut)
    await wait_until_halt(dut)
    dut._log.info("debug is: %s", dut.debug.value)
    dut._log.info("microinstr = %s", dut.control.signals.value)

    dut._log.info("register file = %s", dut.rbank.bank.value)
    # await ClockCycles(dut.clk, num_cycles=20, rising=False)

async def wait_until_diff_ir(dut):
    while not dut.ir.value.is_resolvable:
        await FallingEdge(dut.clk)
    current_ir = dut.ir.value
    
    while True:
        #import pdb; pdb.set_trace()
        if dut.ir.value.is_resolvable and dut.ir.value != current_ir:
            return
        current_ir = dut.ir.value
        dut._log.info("ir still the same, waiting!")
        await FallingEdge(dut.clk)

async def wait_until_halt(dut):
    while True:
        if dut.ir.value.is_resolvable and dut.ir.value == BinaryValue(value=int("0xffff", base=16), n_bits=16):
            return 
        
        await FallingEdge(dut.clk)
