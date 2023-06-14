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
    dut.run <= 0
    dut.code_w_en <= 0

    # wait a bit, 2 clk cycles
    await Timer(20, units="ns")
    await FallingEdge(dut.clk)

    # write program
    dut.code_w_en <= 1
    for i, l in enumerate(test_program):
        dut.code_addr_in <= i
        dut.code_in <= BinaryValue(l)
        await FallingEdge(dut.clk)

    # im in a falling edge, and code has been written

    dut.code_w_en <= 0
    dut.run <= 1

    dut._log.info("arranco a ejecutar")

    # memory has been written
    for i in range(20):
        await FallingEdge(dut.clk)
        dut._log.info("debug is: %s", dut.debug.value)
        dut._log.info("microinstr = %s", dut.control.signals.value)
        # await ClockCycles(dut.clk, num_cycles=20, rising=False)