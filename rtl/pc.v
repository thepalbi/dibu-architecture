`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/12/2023 10:06:28 PM
// Design Name: 
// Module Name: pc
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


module pc(clk, inc, out);
    // clk: clock signal
    input clk;
    // inc: if enabled during clk rising edge, pc will be incremented + 1
    input inc;
    // out: value of the pc register
    output reg [8:0] out;
    
    always @ (posedge clk) begin
        // we should be able to read the current value + increment in one clk rising edge
        if (inc)
            out <= out + 1;
    end
endmodule
