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

VERILOG_SOURCES = "datapath.v pc_module.v register.v memory.v control_unit.v register_bank.v alu.v"
TOPMODEL = "datapath"


@cocotb.test()
async def test_one_register_not(dut):
    test_program = """mov r0 0u4
    mov r3 0xf0
    lsr r5 r3 r0
    not r4 r3
    mov r4 r4
    mov r5 r5
    halt 
    """
    test_compiled_program, _ = assemble(parse(test_program))
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

    # memory has been written
    await wait_until_halt(dut)

    assert dut.rbank.bank.value[3] == int("0xf0", base=16)
    assert dut.rbank.bank.value[4] == int("0x0f", base=16)
    assert dut.rbank.bank.value[5] == int("0x0f", base=16)


@cocotb.test()
async def test_two_registers_add(dut):
    test_program = """mov r3 0xf0
    mov r4 0x01
    add r5 r4 r3
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

    # memory has been written
    await wait_until_halt(dut)

    assert dut.rbank.bank.value[5] == int("0xf1", base=16)


@cocotb.test()
async def test_addi_macro(dut):
    test_program = """mov r3 0xf0
    addi r3 0d1
    jmp test
    halt 
    test: addi r3 0d2
    halt
    """
    test_compiled_program = assemble(parse(test_program), macros=True)

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

    # memory has been written
    await wait_until_halt(dut)

    assert dut.rbank.bank.value[3] == int("0xf3", base=16)


@cocotb.test()
async def test_movf(dut):
    test_program = """mov r3 0x01
    mov r4 0x00
    sub r5 r4 r3
    movf r5
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

    # memory has been written
    await wait_until_halt(dut)

    assert dut.rbank.bank.value[5] == int("00010010", base=2)


@cocotb.test()
async def test_store_load_direct(dut):
    test_program = """mov r3 0x13
    str [0x15] r3
    load r4 [0x15]
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

    assert dut.rbank.bank.value[4] == int("0x13", base=16)


@cocotb.test()
async def test_store_load_direct(dut):
    test_program = """mov r3 0x13
    str [0x15] r3
    load r4 [0x15]
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

    assert dut.rbank.bank.value[4] == int("0x13", base=16)


@cocotb.test()
async def test_write_from_reg_to_ioout(dut):
    test_program = """IO_OUT_ADDR = 0xff
    IO_IN_ADDR = 0xfe
    mov r3 0b00001100
    str [$IO_OUT_ADDR] r3
    load r4 [$IO_IN_ADDR]
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
    dut.io_in.value = BinaryValue(value="0011", n_bits=4)

    dut._log.info("arranco a ejecutar")

    # memory has been written
    await wait_until_halt(dut)

    assert dut.io_out == int("0b1100", base=2)
    assert dut.rbank.bank.value[4] == int("0x03", base=16)


@cocotb.test()
async def test_store_load_indirect(dut):
    test_program = """mov r0 0x15
    mov r3 0x13
    str [r0] r3
    load r4 [r0]
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

    assert dut.rbank.bank.value[4] == int("0x13", base=16)


@cocotb.test()
async def test_simple_jumps_program(dut):
    """
    the program will check if two registers are equal, and jump to save a value in that case
    """
    test_program = """mov r0 0x15
    mov r1 0x15
    cmp r1 r0 ; this should be zero
    je expected
    ; this line is reached if the jump is not taken
    mov r3 0x50
    halt 
    expected: mov r3 0xde
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

    assert dut.rbank.bank.value[3] == int("0xde", base=16)
    # assert cmp didn't affect register bank
    assert dut.rbank.bank.value[1] == int("0x15", base=16)


@cocotb.test()
async def test_simple_jump_not_taken(dut):
    """
    the program will check if two registers are equal, and jump to save a value in that case
    """
    test_program = """mov r0 0x15
    mov r1 0x14
    cmp r1 r0 ; this should be zero
    je expected
    ; this line is reached if the jump is not taken
    mov r3 0x50
    halt 
    expected: mov r3 0xde
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

    assert dut.rbank.bank.value[3] == int("0x50", base=16)
    # assert cmp didn't affect register bank
    assert dut.rbank.bank.value[1] == int("0x14", base=16)


@cocotb.test()
async def test_count_to_30(dut):
    """
    the program will check if two registers are equal, and jump to save a value in that case
    """
    test_program = """mov r0 0d30
    mov r1 0d0
    mov r2 0d1
    move1: add r1 r1 r2 ; increase target register
    sub r0 r0 r2 ; substract from counter
    jne move1 ; equals to jnz
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
    await wait_until_halt(dut, max_clks=1000)

    assert dut.rbank.bank.value[1] == 30


@cocotb.test()
async def test_call_and_ret(dut):
    test_program = """call first
    mov r3 0x12
    halt
    first: mov r4 0x23
    ret 
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
    await wait_until_halt(dut, max_clks=1000)

    assert dut.rbank.bank.value[4] == int("0x23", base=16)
    assert dut.rbank.bank.value[3] == int("0x12", base=16)


@cocotb.test()
async def test_multiple_call_and_ret(dut):
    test_program = """call first
    mov r3 0x12
    halt
    first: mov r4 0x23
    call second
    ret
    halt
    second: mov r2 0x10
    ret 
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

    # memory has been written
    await wait_until_halt(dut)

    assert dut.rbank.bank.value[4] == int("0x23", base=16)
    assert dut.rbank.bank.value[3] == int("0x12", base=16)
    assert dut.rbank.bank.value[2] == int("0x10", base=16)


@cocotb.test()
async def test_demo_program(dut):
    with open("/home/pablo/facultad/dibu-architecture/rtl_tests/demo-program.asm", "r") as f:
        test_program = f.read()
    test_compiled_program, _ = assemble(parse(test_program), macros=True)
    print("programa compilado: \n%s" % (test_compiled_program))

    dut.run.value = 0
    dut.code_w_en.value = 0

    cocotb.start_soon(Clock(dut.clk, 8, units="ns").start())

    # wait a bit, 2 clk cycles
    await Timer(16, units="ns")
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

    # memory has been written
    await wait_until_halt(dut, max_clks=2000)


async def wait_until_halt(dut, max_clks=100):
    clks_left = max_clks
    while clks_left > 0:
        if dut.ir.value.is_resolvable and dut.ir.value == BinaryValue(value=int("0xffff", base=16), n_bits=16):
            return
        if clks_left == 0:
            raise Exception("clks timed out waiting for halt")
        clks_left -= 1
        await FallingEdge(dut.clk)


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
