all: test_data
IVERLOG_FLAGS := -Wall

generate:
	@python generate_alu_data.py > alu_data.mem

test_%: generate
	iverilog $(IVERLOG_FLAGS) -o $(patsubst test_%, test_%.out, $@) $(patsubst test_%, %.v, $@) $(patsubst %, %.v, $@)
	vvp $(patsubst test_%,test_%.out,$@)
