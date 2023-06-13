`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/12/2023 10:06:50 PM
// Design Name: 
// Module Name: register
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


module register #(parameter width=8) (clk, w_en, d_in, d_out);
    input clk;
    // w_en: write enable
    input w_en;
    // d_in: data in, will be written in next posedge when w_en high
    input [width-1:0] d_in;

    // d_out: data out
    output reg [width-1:0] d_out;

    always @ (posedge clk) begin
        if (w_en)
            d_out <= d_in;
    end

endmodule
