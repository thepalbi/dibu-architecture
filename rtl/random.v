`timescale 1ns / 1ps

`include "constants.v"

// simple lfsr: linear feedback shift register
// based on https://docs.xilinx.com/v/u/en-US/xapp052
module random (clk, in, rnd_out);
    // clk: clock signal
    input clk;
    input [7:0] in;

    // d_out: data out
    output reg [7:0] rnd_out;
    
    wire [7:0] shifted;
    assign shifted = in << 1;
    
    wire new_bit;
    // taps 8,6,5,4 
    assign new_bit = in[7] ^ in[5] ^ in[4] ^ in[3];

    always @ (*) begin    
        rnd_out <= shifted | {7'd0, new_bit};
    end
endmodule
