`timescale 1ns / 1ps

// `include "constants.v"
// `include "signals.v"

// module datapath(clk, run, code_w_en, code_addr_in, code_in, io_in, io_out);

module dibu(clk, rst, io_in, io_out);
    input clk, rst;
    input [3:0] io_in;
    output [3:0] io_out;
    datapath d(
        .clk(clk),
        .rst(rst),
        .run('d1),
        .code_w_en('d0),
        .code_addr_in('d0),
        .code_in('d0),
        .io_in(io_in),
        .io_out(io_out)
    );
endmodule
