# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
COMPILE_ARGS := -Wall -I $(PWD)/../rtl

# extracted from the test files
TOPLEVEL := $(shell python discover_tests.py $(MODULE) toplevel)
TESTS := $(shell python discover_tests.py $(MODULE) tests)
SOURCES := $(shell python discover_tests.py $(MODULE) sources)

VERILOG_SOURCES := $(foreach s,$(SOURCES),$(PWD)/../rtl/$(s))

# include cocotb's make rules to take care of the simulator setup
include $(shell python -m cocotb.config --makefiles)/Makefile.sim

regression: $(TESTS)

test_%:
	@echo "Running test: $@"
	$(MAKE) sim TESTCASE=$@
