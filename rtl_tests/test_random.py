from os import path
import cocotb
from cocotb.triggers import Timer, FallingEdge, RisingEdge, ClockCycles
from cocotb.handle import Force
from cocotb.clock import Clock
from cocotb.binary import BinaryValue
import sys

VERILOG_SOURCES = "random.v"
TOPMODEL = "random"

@cocotb.test()
async def test_basic_random(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    await Timer(200, units="ns")
