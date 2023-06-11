# Makefile

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/register_alu_machine.v
VERILOG_SOURCES += $(PWD)/register_bank.v
VERILOG_SOURCES += $(PWD)/alu.v
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = register_alu_machine

# MODULE is the basename of the Python test file
MODULE = tests

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
