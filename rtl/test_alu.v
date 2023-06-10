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
    reg ignore_flags;
    
    // test data
    // vectornum is the index in the testvectors arr
    reg [31:0] vectornum, errors;
    reg [35:0] testvectors [0:1000];

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
        {a, b, expected_out, alu_op, expected_flags, ignore_flags} = testvectors[vectornum]; 
    
    // main test harness
    always @ (negedge clk) begin
        // wait for any data to be loaded before starting test harness on negedge clk
        // todo(pablo): checkear con david
        if (expected_out !== 8'bx) begin
            $display("TEST %d", vectornum);
            // todo: add assertion over flags
            if (out !== expected_out || (flags !== expected_flags) & ~ignore_flags) begin
                // error
                $display("FAILURE: out got = %h", out);
                $display("             exp = %h", expected_out);
                if (~ignore_flags) begin
                    $display("       flags     = 000PZONC");
                    $display("       flags got = %b", flags);
                    $display("             exp = %b", expected_flags);
                end
                errors = errors + 1;
            end
            vectornum = vectornum + 1;
            if (testvectors[vectornum] === 36'bx) begin
                $display("%d tests ran, %d failed", vectornum, errors);
                $finish;
            end
        end
    end
endmodule
