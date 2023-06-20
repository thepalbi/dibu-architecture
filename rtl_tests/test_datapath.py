from os import path
import cocotb
from cocotb.triggers import Timer, FallingEdge, RisingEdge, ClockCycles
from cocotb.handle import Force
from cocotb.clock import Clock
from cocotb.binary import BinaryValue
import sys

CURRENT_DIR = path.dirname(path.realpath(__file__))
sys.path.append(path.join(CURRENT_DIR, "../"))
from dibuparser import parse, assemble


@cocotb.test()
async def test_one_register_not(dut):
    test_program = """mov r3 0xf0
    not r4 r3
    halt 
    """
    test_compiled_program = assemble(parse(test_program))
    print("programa compilado: \n%s" % (test_compiled_program))

    dut.run.value = 0
    dut.code_w_en.value = 0
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

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
    await wait_until_halt(dut)

    assert dut.rbank.bank.value[3] == int("0xf0", base=16)
    assert dut.rbank.bank.value[4] == int("0x0f", base=16)


@cocotb.test()
async def test_two_registers_add(dut):
    import pdb; pdb.set_trace()
    test_program = """mov r3 0xf0
    mov r4 0x01
    add r5 r4 r3
    halt 
    """
    test_compiled_program = assemble(parse(test_program))
    print("programa compilado: \n%s" % (test_compiled_program))

    dut.pc.value = Force(0)
    dut.run.value = 0
    dut.code_w_en.value = 0
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

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
    await wait_until_halt(dut)

    assert dut.rbank.bank.value[5] == int("0xf1", base=16)


async def wait_until_diff_ir(dut):
    while not dut.ir.value.is_resolvable:
        await FallingEdge(dut.clk)
    current_ir = dut.ir.value

    while True:
        # import pdb; pdb.set_trace()
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
