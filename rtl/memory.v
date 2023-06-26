`timescale 1ns / 1ps

`include "constants.v"

module memory_bank #(
    parameter word_size=`DATA_WORD_SIZE,
    parameter addr_size=`DATA_ADDR_SIZE
) (
    clk,
    w_en,
    addr,
    d_in,
    d_out,
);
    // clk: clock signal
    // w_en: write enable
    input clk, w_en;

    // addr: address for read/write operations
    input [addr_size-1:0] addr;
    // d_in: data in
    input [word_size-1:0] d_in;

    // d_out: data out
    output reg [word_size-1:0] d_out;

    // main memory bank
    reg [word_size-1:0] bank [0:addr_size-1];

    assign d_out = bank[addr];

    always @ (posedge clk) begin
        if (w_en)
            bank[addr] <= d_in;
    end
endmodule
