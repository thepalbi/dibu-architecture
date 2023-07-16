`timescale 1ns / 1ps

// Based on https://digilent.com/reference/learn/programmable-logic/tutorials/counter-and-clock-divider/start
module clk_divider #(parameter divisor=100) (clk_in, rst, clk_out);
    input clk_in, rst;
    output reg clk_out;

    reg [31:0] count;
     
    always @ (posedge clk_in, posedge rst) begin
        if (rst == 1'b1)
            count <= 32'b0;
        else if (count == divisor - 1)
            count <= 32'b0;
        else
            count <= count + 1;
    end
    
    always @ (posedge clk_in, posedge rst) begin
        if (rst == 1'b1)
            clk_out <= 1'b0;
        else if (count == divisor - 1)
            clk_out <= ~clk_out;
        else
            clk_out <= clk_out;
    end
endmodule