`timescale 1ns / 1ps

`include "constants.v"

module pc_module(clk, rst, pc_inc, pc_ref_inc, pc_ref_dec, pc_set, pc_set_value, pc_out, err);
    // utility signals
    input clk;
    input rst;

    input pc_inc, pc_ref_inc, pc_ref_dec, pc_set;
    input [8:0] pc_set_value;

    // outputs
    output wire [8:0] pc_out;
    output reg err;

    reg [2:0] pc_ref;
    reg [8:0] pc_bank [0:7];
    
    integer i;

    initial
    begin    
        for (i=0; i<8; i=i+1) begin
            pc_bank[i] = 9'd0;
        end
        
        pc_ref = 3'd0;
        err = 0;
    end

    always @ (posedge rst) begin
        if (rst) begin
            for (i=0; i<8; i=i+1) begin
                pc_bank[i] <= 9'd0;
            end

            pc_ref <= 3'd0;
            err <= 0;
        end
    end

    always @ (posedge clk) begin
        if (pc_inc) begin
            pc_bank[pc_ref] <= pc_bank[pc_ref] + 1;
        end
        
        if (pc_set) begin
            pc_bank[pc_ref] <= pc_set_value;
        end
        
        if (pc_ref_inc) begin
            if (pc_ref == 3'd7) begin
                err <= 1;
            end
            else begin
                pc_ref <= pc_ref + 1;
            end 
        end
        
        if (pc_ref_dec) begin
            if (pc_ref == 3'd0) begin
                err <= 1;
            end
            else begin
                pc_ref <= pc_ref - 1;
            end
        end
    end

    // combinational assings
    assign pc_out = pc_bank[pc_ref];
    
endmodule
