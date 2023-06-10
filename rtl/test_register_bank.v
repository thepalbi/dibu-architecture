`timescale 1ns / 1ps

module test_register_bank();
    // utils
    reg clk;

    // test inputs
    reg [7:0] d;
    reg [2:0] ri_a, ri_b, ri_d;
    reg rw;
    
    // test outputs
    wire [7:0] a, b;
    
    register_bank uut(
        .clk(clk),
        .ri_a(ri_a),
        .ri_b(ri_b),
        .ri_d(ri_d),
        .rw(rw),
        .a(a),
        .b(b),
        .d(d)
    );
    
    // read test data and clear auxiliary vars
    initial begin
        $display("starting register bank test suite");
        clk = 0;
        d = 0;
        ri_a = 0;
        ri_b = 0;
        ri_d = 0;
        rw = 0;

        // r0 <- 7
        rw = 1;
        d = 8'd7;
        // clock cycle
        clk = 1; #5; clk = 0; #5;
        // r1 <- 5
        ri_d = 3'd1;
        d = 8'd5;
        // clock cycle
        clk = 1; #5; clk = 0; #5;
        // read registers and assert
        rw = 0;
        ri_a = 3'd0;
        ri_b = 3'd1;
        // clock cycle
        clk = 1; #5; clk = 0; #5;

        if (a !== 8'd7) $display("r0 assertion failed; got = %d, exp = %d", a, 8'd7);
        if (b !== 8'd5) $display("r1 assertion failed; got = %d, exp = %d", b, 8'd5);
        $finish;
    end

endmodule
