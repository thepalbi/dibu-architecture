`timescale 1ns / 1ps

module register_alu_machine(clk, alu_op, wen, wd, rw, ri_a, ri_b, ri_d, flags, out);
    // utility signals
    input clk;

    // control signals when using as dut
    input rw;
    // wen: write enable wd into alu
    input wen;
    input [2:0] alu_op;
    input [2:0] ri_a, ri_b, ri_d;
    input [7:0] wd;

    // routed inside dut
    wire [7:0] alu_out, alu_a, alu_b, w_flags;
    wire [7:0] reg_data_in;

    // outputs
    output reg [7:0] flags;
    output reg [7:0] out;

    register_bank rbank(
        .clk(clk),
        .ri_a(ri_a),
        .ri_b(ri_b),
        .ri_d(ri_d),
        .rw(rw),
        .d(reg_data_in),
        .a(alu_a),
        .b(alu_b)
    );

    alu alu_unit(
        .a(alu_a),
        .b(alu_b),
        .out(alu_out),
        .flags(w_flags),
        .op(alu_op)
    );

    // sequential
    always @ (negedge clk) begin
        flags <= w_flags;
        out <= alu_out;
    end

    // combinational assings
    assign reg_data_in = wen ? wd : alu_out;
    
endmodule
