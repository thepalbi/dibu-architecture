all: alu_test

alu_test:
	@python generate_alu_data.py > alu_data.mem
	@iverilog -Wall -o test_alu.out alu.v test_alu.v
	@vvp test_alu.out
