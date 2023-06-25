`timescale 1ns / 1ps

`include "constants.v"
`include "signals.v"

module ctrl_unit(clk, opcode, signals);
    // clk: clock signal
    input clk;
    // opcode, which corresponds to the ir[15:11] bits
    input [4:0] opcode;
    // signals: output signals from the contorl unit
    output [`signals_size-1:0] signals;

    // todo: parametrize this por favor
    reg [`store_word_size-1:0] store [0:31];
    // next_addr are the address bits from the microsintruction
    wire [`micro_addr_size-1:0] next_addr;
    // chosen next address is the output of the microsequencer block
    reg [`micro_addr_size-1:0] chosen_next_addr;
    // bit should be set if we are on the decision state, aka
    // the state where the control unit decides which instruction is being executed
    wire is_decision_state;

    // current is the current microinstruction
    reg [`store_word_size-1:0] current;

    // combinational block
    assign is_decision_state = current[0];
    assign signals = current[`signals_size:1];
    assign next_addr = current[`store_word_size-1:`store_word_size-`micro_addr_size];

    integer i;

    // load microprogram in rom
    initial begin
        $display("reading microprogram into store");
        // if in cocotb test load from here
        `ifdef COCOTB_SIM
        $readmemb("../rtl/microprogram_clean.mem", store);
        `else
        // if compiling without cocos read from current dir
        $readmemb("./microprogram_clean.mem", store);
        `endif
        current = 'd0;
    end

    // todo(pablo): maybe extract
    // microsequencer block
    always @ (*) begin
        if (is_decision_state) begin
            casex (opcode) 
                // mov r1 r2
                5'b00111: chosen_next_addr <= `micro_addr_size'd2;
                // mov r1 imm
                5'b01000: chosen_next_addr <= `micro_addr_size'd6;
                // alu operations
                5'b00???: chosen_next_addr <= `micro_addr_size'd4;
                // movf
                5'b01011: chosen_next_addr <= `micro_addr_size'd7;
                // load direct
                5'b10000: chosen_next_addr <= `micro_addr_size'd8;
                // store direct
                5'b10001: chosen_next_addr <= `micro_addr_size'd11;
                default: begin
                    $display("unsupported instruction: %b", opcode);
                    // if not supported, go to fetch
                    chosen_next_addr <= `micro_addr_size'd0;
                end
            endcase
        end else
            // base case, where each microinstruction decides it's next addr
            chosen_next_addr <= next_addr;
    end

    // sequential block
    always @ (posedge clk) begin
        current <= store[chosen_next_addr];
        $display("microinstr: %h", chosen_next_addr);
    end
endmodule
