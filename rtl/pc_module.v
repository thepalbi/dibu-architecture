module pc_module(clk, inc, inc_pc_ref, dec_pc_ref, pc_set, pc_set_value, pc_out, err);
    // utility signals
    input clk;

    input inc, inc_pc_ref, dec_pc_ref, pc_set;
    input [8:0] pc_set_value;

    // outputs
    output wire [8:0] pc_out;
    output reg err;

    reg [2:0] pc_ref;
    reg [8:0] pc_bank [0:7];
    
    initial
    begin
       pc_bank[0] = 9'd0;
       pc_bank[1] = 9'd0;
       pc_bank[2] = 9'd0;
       pc_bank[3] = 9'd0;
       pc_bank[4] = 9'd0;
       pc_bank[5] = 9'd0;
       pc_bank[6] = 9'd0;
       pc_bank[7] = 9'd0;
       
       pc_ref = 3'd0;
       err = 0;
    end

    always @ (posedge clk) begin
        if (inc) begin
            pc_bank[pc_ref] <= pc_bank[pc_ref] + 1;
        end
        
        if (pc_set) begin
            pc_bank[pc_ref] <= pc_set_value;
        end
        
        if (inc_pc_ref) begin
            if (pc_ref == 3'd7) begin
                err <= 1;
            end
            else begin
                pc_ref <= pc_ref + 1;
            end 
        end
        
        if (dec_pc_ref) begin
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
