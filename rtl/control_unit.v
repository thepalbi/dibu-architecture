`timescale 1ns / 1ps

`include "constants.v"
`include "signals.v"

module ctrl_unit(clk, opcode, flags, signals);
    // clk: clock signal
    input clk;
    // opcode, which corresponds to the ir[15:11] bits
    input [4:0] opcode;
    input [7:0] flags;
    // signals: output signals from the contorl unit
    output [`signals_size-1:0] signals;

    // todo: parametrize this por favor
    reg [`store_word_size-1:0] store [0:(2 ** `micro_addr_size)-1];
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
                // load indirect
                5'b10010: chosen_next_addr <= `micro_addr_size'd8;
                // load direct
                5'b10000: chosen_next_addr <= `micro_addr_size'd9;
                // store indirect
                5'b10011: chosen_next_addr <= `micro_addr_size'd12;
                // store direct
                5'b10001: chosen_next_addr <= `micro_addr_size'd13;
                // call
                5'b11100: chosen_next_addr <= `micro_addr_size'd18;
                // ret
                5'b11101: chosen_next_addr <= `micro_addr_size'd20;
                // cmp
                5'b01001: chosen_next_addr <= `micro_addr_size'd21;
                // jumps logic
                5'b11???: begin
                    // possible targets
                    `define JUMP_TAKEN `micro_addr_size'd17
                    `define FETCH `micro_addr_size'd0
                    if ((opcode[2:0] === 3'd0) |
                        (opcode[2:0] === `JE & flags[`FLAG_ZERO]) |
                        (opcode[2:0] === `JNE & ~flags[`FLAG_ZERO]) |
                        (opcode[2:0] === `JN & flags[`FLAG_NEGATIVE]))
                        chosen_next_addr <= `JUMP_TAKEN;
                    else
                        chosen_next_addr <= `FETCH;
                end
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
        //$display("microinstr: %h", chosen_next_addr);
    end
endmodule
