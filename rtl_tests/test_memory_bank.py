import cocotb
from cocotb.triggers import Timer, FallingEdge, RisingEdge
from cocotb.clock import Clock

test_bytes = [
    '0a',
    '0b',
    '0c',
    '0d',
    '0e',
    '0f',
    '1f',
    'ff',
]
test_bytes = [int(b, base=16) for b in test_bytes]


@cocotb.test()
async def read_then_write(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut._log.info("about to write all these bytes: %s" % (test_bytes))

    # wait a bit, 2 clk cycles
    await Timer(20, units="ns")

    # write all bytes in testbytes
    dut.w_en.value = 1
    for i, b in enumerate(test_bytes):
        # after falling edge, write first register
        await FallingEdge(dut.clk)
        dut.addr.value = i
        dut.d_in.value = b

    # after falling edge, read register
    await FallingEdge(dut.clk)

    # switch to read
    dut.w_en.value = 0
    for i, b in enumerate(test_bytes):
        dut.addr.value = i
        await RisingEdge(dut.clk)
        # wait for the middle of rising edge
        await Timer(2, units="ns")
        # assert once we are halfway through the cycle
        assert dut.d_out.value == b, "expected mem[%d] to be %d" % (i, b)


@cocotb.test()
async def read_write_interleaved(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut._log.info("about to write all these bytes: %s" % (test_bytes))

    # wait a bit, 2 clk cycles
    await Timer(20, units="ns")

    await FallingEdge(dut.clk)

    # this should write a byte in once cycle, and read in the other, total two cycles per r/w
    # start in negedge
    for i, b in enumerate(test_bytes):
        # write single byte
        dut.w_en.value = 1
        dut.addr.value = i
        dut.d_in.value = b
        await FallingEdge(dut.clk)

        # now we are after the first cycle, switch to read
        dut.w_en.value = 0
        await RisingEdge(dut.clk)
        # wait for the middle of rising edge
        await Timer(2, units="ns")
        # assert once we are halfway through the cycle, that is 1.5 cycles in
        assert dut.d_out.value == b, "expected mem[%d] to be %d" % (i, b)

        # for to falling edge for next test iteration
        await FallingEdge(dut.clk)
