`timescale 1ns / 1ps

module pc_module(clk, pc, inc, inc_pc_ref, dec_pc_ref, pc_out, err);
    // utility signals
    input clk;

    // control signals when using as dut
    input inc, inc_pc_ref, dec_pc_ref;

    // outputs
    output reg [8:0] pc_out;
    output reg err;

    reg [2:0] pc_ref;
    reg [8:0] pc_bank [0:7];

    always @ (posedge clk) begin
        // we should be able to read the current value + increment in one clk rising edge
        if (inc)
            pc_bank[pc_ref] <= pc_bank[pc_ref] + 1;
        if (inc_pc_ref)
            if (pc_ref == 3'd7)
                err <= 1
            else
                pc_ref <= pc_ref + 1
        if (dec_pc_ref)
            if (pc_ref == 3'd0)
                err <= 1
            else
                pc_ref <= pc_ref - 1
    end

    // combinational assings
    assign pc_out = pc_bank[pc_ref]
    
endmodule
