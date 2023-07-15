`timescale 1ns / 1ps

`include "constants.v"
`define word_size 16
`define addr_size 9

module pp_memory (
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
    input [9:0] addr;
    // d_in: data in
    input [15:0] d_in;

    // d_out: data out
    output reg [15:0] d_out;

    // main memory bank
    reg [15:0] bank [0:1023];
    
    initial begin
        $readmemb("./debug3.mem", bank);
    end
    
    always @ (*)
        d_out <= bank[addr];

    always @ (posedge clk) begin
        if (w_en)
            bank[addr] <= d_in;
    end
endmodule
