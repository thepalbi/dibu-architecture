import cocotb
from cocotb.triggers import Timer, FallingEdge, RisingEdge
from cocotb.clock import Clock

VERILOG_SOURCES = "pc_module.v"
TOPMODEL = "pc_module"

@cocotb.test()
async def test_set_pc_to_desired_value(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

 
    await reset_dut(dut)

    await FallingEdge(dut.clk)
    dut.pc_ref_inc.value = 1
    dut.pc_set_value.value = int("0x10f", base=16)

    await FallingEdge(dut.clk)
    dut.pc_ref_inc.value = 0
    dut.pc_set.value = 1

    await FallingEdge(dut.clk)
    dut.pc_set.value = 0

    await FallingEdge(dut.clk)

    assert dut.pc_out.value == int("0x10f", base=16)
    assert dut.pc_bank[0].value == int("0x0", base=16)

@cocotb.test()
async def test_error_when_pc_ref_above_limit(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    await reset_dut(dut)

    await FallingEdge(dut.clk)
    dut.pc_ref.value = int("0x7", base=16)

    await FallingEdge(dut.clk)
    dut.pc_ref_inc.value = 1

    await FallingEdge(dut.clk)
    dut.pc_ref_inc.value = 0

    await FallingEdge(dut.clk)

    assert dut.err.value == 1

@cocotb.test()
async def test_error_when_pc_ref_below_limit(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    await reset_dut(dut)

    await FallingEdge(dut.clk)
    dut.pc_ref_dec.value = 1

    await FallingEdge(dut.clk)
    dut.pc_ref_dec.value = 0

    await FallingEdge(dut.clk)

    assert dut.err.value == 1

@cocotb.test()
async def test_inc_only_increments_current_pc(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    await reset_dut(dut)

    await FallingEdge(dut.clk)
    dut.pc_ref_inc.value = 1

    await FallingEdge(dut.clk)
    dut.pc_ref_inc.value = 0
    dut.pc_inc.value = 1

    await FallingEdge(dut.clk)
    dut.pc_inc.value = 0

    await FallingEdge(dut.clk)
    dut.pc_inc.value = 1

    await FallingEdge(dut.clk)
    dut.pc_inc.value = 0

    assert dut.pc_bank[0].value == int("0x0", base=16)
    assert dut.pc_bank[1].value == int("0x2", base=16)
    assert dut.pc_bank[2].value == int("0x0", base=16)
    assert dut.err.value == 0

async def reset_dut(dut):
    dut.rst.value = 1
    await Timer(20, units="ns")
    dut.rst.value = 0
