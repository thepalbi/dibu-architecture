import cocotb
from cocotb.triggers import Timer, FallingEdge, RisingEdge
from cocotb.clock import Clock
from dibu.alu import ALUOp

@cocotb.test()
async def register_alu_machine(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # set initial stuff
    dut.alu_op.value = ALUOp.NOT.value

    # wait a bit, 2 clk cycles
    await Timer(20, units="ns")

    # after falling edge, write first register
    await FallingEdge(dut.clk)

    # r3 <- 0x0f
    dut.rw.value = 1
    dut.wen.value = 1
    dut.ri_d.value = 3
    dut.wd.value = int('0f', base=16)
    await FallingEdge(dut.clk)

    # read ra into r3
    dut.rw.value = 0
    dut.ri_a.value = 3
    # do not as alu op
    dut.alu_op.value = ALUOp.NOT.value
    await FallingEdge(dut.clk)
    # values in dut are written on negedge, so wait till next rising edge
    await RisingEdge(dut.clk)

    dut._log.info("out is %s" % (dut.out.value))
    dut._log.info("flags is %s" % (dut.flags.value))

    assert dut.out.value == int('f0', base=16), "expected alu out for have not r3"
    assert dut.flags.value[6] == 1, "expected N flags to be on"
