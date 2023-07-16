`timescale 1ns / 1ps

// `include "constants.v"
// `include "signals.v"

// module datapath(clk, run, code_w_en, code_addr_in, code_in, io_in, io_out);

module dibu(clk, rst, io_in, io_out);
    input clk, rst;
    input [3:0] io_in;
    output [3:0] io_out;
    
    wire divided_clk;
    clk_divider #(500) clk_regulator(
        .clk_in(clk),
        .rst(rst),
        .clk_out(divided_clk)
    );
    
    datapath d(
        .clk(divided_clk),
        .rst(rst),
        .run('d1),
        .code_w_en('d0),
        .code_addr_in('d0),
        .code_in('d0),
        .io_in(io_in),
        .io_out(io_out)
    );
endmodule
