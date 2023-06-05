`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/05/2023 06:17:36 PM
// Design Name: 
// Module Name: test_alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "constants.v"

module test_alu();

    // test inputs
    reg [7:0] a,b;
    reg [3:0] alu_op;
    
    // test outputs
    wire [7:0] out;
    wire zero, negative, carry, overflow, parity;

    alu uut(
        .a(a),
        .b(b),
        .op(alu_op),
        .out(out),
        .zero(zero),
        .negative(negative),
        .carry(carry),
        .overflow(overflow),
        .parity(parity)
    );
    
    initial begin;
        a = 8'd0;
        b = 8'd0;
        alu_op = `OP_SUM;
        
        #10;
        
        a = 8'd5;
        b = 8'd5;
        
        #10;
        
        a = 8'd5;
        b = 8'd10;
    end


endmodule
