`timescale 1ns / 1ps
//
// register_bank is the DiBU main register bank. ri_* are the registers index.
// a, b are the read registers, and d is the input for writing a register.
// Two registers can be read at the same time, but only one can be written.
//
module register_bank(clk, ri_a, ri_b, ri_d, rw, d, a, b);
    // clk is the main clock signal
    input wire clk;
    // rw selects if the register write or read on posedge of clk.
    // rw == 0: READ
    // rw == 1: WRITE
    input wire rw;
    // ri_* are the register index
    input [2:0] ri_a, ri_b, ri_d;
    // d is the write date
    input [7:0] d;
    // a, b are the registers out
    output reg [7:0] a, b;

    reg [7:0] bank [0:7];

    integer i;
    initial begin
        for (i = 0; i <= 7; i=i+1) begin
            bank[i] = 8'd0;
        end
        a = 0;
        b = 0;
    end

    always @ (posedge clk) begin
        if (rw) begin
            // write
            bank[ri_d] <= d;
        end else begin
            // read
            a <= bank[ri_a];
            b <= bank[ri_b];
        end
    end
endmodule
