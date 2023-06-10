all: test_data
IVERLOG_FLAGS := -Wall

test_data:
	@python generate_alu_data.py > alu_data.mem

test_%: test_data
	iverilog $(IVERLOG_FLAGS) -o $(patsubst test_%, test_%.out, $@) $(patsubst test_%, %.v, $@) $(patsubst %, %.v, $@)
	vvp $(patsubst test_%,test_%.out,$@)
