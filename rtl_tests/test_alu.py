from bitstring import Bits
import cocotb
from cocotb.triggers import Timer
from dibu.alu import Model,  ALUOp
from typing import Tuple, List


VERILOG_SOURCES = "alu.v"
TOPMODEL = "alu"

@cocotb.test()
async def basic_add_op(dut):
    dut.a.value = -1
    dut.b.value = 10
    dut.op.value = int(ALUOp.ADD.value)

    await Timer(time=10, units="ns")

    assert dut.out.value == 9