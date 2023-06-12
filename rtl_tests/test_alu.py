from bitstring import Bits
import cocotb
from cocotb.triggers import Timer
from dibu.alu import Model,  ALUOp
from typing import Tuple, List


@cocotb.test()
async def basic_register_write_read(dut):
    testcases: List[Tuple[int, int, ALUOp]] = [
        # a, b, expected, op
        (10, 11, ALUOp.ADD),
        (1, -1, ALUOp.ADD),
        (1, -1, ALUOp.SUB),
        (-1, -1,  ALUOp.ADD),
    ]

    alu_model = Model()

    await Timer(time=10, units="ns")
    for a, b, op in testcases:
        dut.a.value = a
        dut.b.value = b
        dut.op.value = int(op.value)

        await Timer(time=10, units="ns")

        assert dut.out.value == alu_model.evaluate(
            a, op, b), "got value other than model"
