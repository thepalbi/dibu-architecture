import cocotb
from cocotb.triggers import Timer, FallingEdge, RisingEdge
from cocotb.clock import Clock


@cocotb.test()
async def basic_register_write_read(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # wait a bit, 2 clk cycles
    await Timer(20, units="ns")

    # after falling edge, write first register
    await FallingEdge(dut.clk)
    dut.rw.value = 1
    dut.d.value = 7
    dut.ri_d.value = 3

    # after falling edge, read register
    await FallingEdge(dut.clk)
    dut.rw.value = 0
    dut.ri_a.value = 3

    await RisingEdge(dut.clk)
    # wait for the middle of rising edge
    await Timer(2, units="ns")

    assert dut.a == 7, "expected r3 to have 7"