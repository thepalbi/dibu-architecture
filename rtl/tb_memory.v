`timescale 1ns / 1ps

module tb_memory(clk, w_en, addr, d_in, d_out);
    input clk, w_en;
    input [7:0] d_in;
    input [8:0] addr;
    output [7:0] d_out;

    memory_bank mem(
        .clk(clk),
        .w_en(w_en),
        .addr(addr),
        .d_in(d_in),
        .d_out(d_out)
    );

endmodule
