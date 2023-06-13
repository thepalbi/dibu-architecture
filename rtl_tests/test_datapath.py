import cocotb
from cocotb.triggers import Timer, FallingEdge, RisingEdge, ClockCycles
from cocotb.clock import Clock
from cocotb.binary import BinaryValue


test_program = [
    "0100001111110000",
    "0011110000011000",
    "0011010100100000"
]


@cocotb.test()
async def datapath_simple_test(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.run.value.value = 0
    dut.code_w_en.value = 0

    # wait a bit, 2 clk cycles
    await Timer(20, units="ns")
    await FallingEdge(dut.clk)

    # write program
    dut.code_w_en.value = 1
    for i, l in enumerate(test_program):
        dut.code_addr_in.value = i
        dut.code_in.value = BinaryValue(l)
        await FallingEdge(dut.clk)

    # im in a falling edge, and code has been written

    dut.code_w_en.value = 0
    dut.run.value = 1

    # memory has been written
    await ClockCycles(dut.clk, num_cycles=20, rising=False)