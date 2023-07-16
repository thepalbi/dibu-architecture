`timescale 1ns / 1ps

`include "constants.v"

module random (clk, rnd_out);
    // clk: clock signal
    input clk;

    // d_out: data out
    output reg [7:0] rnd_out;

    initial begin
        // the "macro" to dump signals
        `ifdef COCOTB_SIM
        $dumpfile ("random.vcd");
        $dumpvars (0, random);
        #1;
        `endif
    end

    always @ (posedge clk) begin    
        rnd_out <= {$random}%255;
    end
endmodule
