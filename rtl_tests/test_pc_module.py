import cocotb
from cocotb.triggers import Timer, FallingEdge, RisingEdge
from cocotb.clock import Clock

VERILOG_SOURCES = "pc_module.v"
TOPMODEL = "pc_module"

@cocotb.test()
async def set_pc_to_desired_value2(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # wait a bit, 2 clk cycles
    await Timer(20, units="ns")

    # after falling edge, write first register
    await FallingEdge(dut.clk)
    dut.inc.value = 1

    # after falling edge, read register
    await FallingEdge(dut.clk)
    dut.inc.value = 0

    await RisingEdge(dut.clk)
    # wait for the middle of rising edge
    await Timer(2, units="ns")

    assert dut.pc_out == 1