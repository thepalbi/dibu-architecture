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
    reg [7:0] expect_a, expect_b;
    
    // test data
    // vectornum is the index in the testvectors arr
    reg [31:0] vectornum, errors;
    reg [22:0] testvectors [0:1000];

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
    
    //
    // clock with a 10ns period
    // 
    always #5 clk = ~clk;
    
    // read test data and clear auxiliary vars
    initial begin
        $display("starting register bank test suite");
        $readmemb("./register_bank_data.mem", testvectors);
        clk = 0;
        d = 0;
        ri_a = 0;
        ri_b = 0;
        ri_d = 0;
        rw = 0;
        vectornum = 0;
        errors = 0;
    end
    
    // on everyposedge, read test data
    always @ (posedge clk) begin
        rw = testvectors[vectornum][0];
        if (rw) begin
            // if writing, vector will contain indexes and data
            {ri_d, d, rw} = testvectors[vectornum][11:0];
            $display("writing r%d <- %d", ri_d, d);
        end else
            // if reading, assert over both registers 
            {ri_a, expect_a, ri_b, expect_b, rw} = testvectors[vectornum];
    end
    
    // main test harness
    always @ (negedge clk) begin
        if (~rw) begin
            $display("TEST %d", vectornum);
            // todo: add assertion over flags
            if (a !== expect_a || b !== expect_b) begin
                // error
                $display("FAILURE: a got = %h", a);
                $display("           exp = %h", expect_a);
                $display("         b got = %h", b);
                $display("           exp = %h", expect_b);
                errors = errors + 1;
            end
        end
        vectornum = vectornum + 1;
        if (testvectors[vectornum] === 23'bx) begin
            $display("%d tests ran, %d failed", vectornum, errors);
            $finish;
        end
    end
endmodule
