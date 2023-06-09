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
    // utils
    reg clk;

    // test inputs
    reg [7:0] a,b,expected_out, expected_flags;
    reg [2:0] alu_op;
    
    // test outputs
    wire [7:0] out;
    wire [7:0] flags;
    wire zero, negative, carry, overflow, parity;
    
    // test data
    // vectornum is the index in the testvectors arr
    reg [31:0] vectornum, errors;
    reg [34:0] testvectors [0:1000];

    alu uut(
        .a(a),
        .b(b),
        .op(alu_op),
        .out(out),
        .flags(flags)
    );
    
    //
    // clock with a 10ns period
    // 
    always #5 clk = ~clk;
    
    // read test data and clear auxiliary vars
    initial begin
        $display("starting alu test suite");
        $readmemb("./alu_data.mem", testvectors);
        clk = 0;
        a = 0;
        b = 0;
        alu_op = 0;
        vectornum = 0;
        errors = 0;
    end
    
    // on everyposedge, read test data
    always @ (posedge clk)
        {a, b, expected_out, alu_op, expected_flags} = testvectors[vectornum]; 
    
    // main test harness
    always @ (negedge clk) begin
        $display("TEST %d", vectornum);
        // todo: add assertion over flags
        if (out !== expected_out) begin
            // error
            $display("FAILURE: got = %d", out);
            $display("         exp = %d", expected_out);
            errors = errors + 1;
        end
        vectornum = vectornum + 1;
        if (testvectors[vectornum] === 35'bx) begin
            $display("%d tests ran, %d failed", vectornum, errors);
            $finish;
        end
    end
endmodule
