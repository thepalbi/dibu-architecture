`timescale 1ns / 1ps

`include "constants.v"
`include "signals.v"

module datapath(clk, run, code_w_en, code_addr_in, code_in, debug);
    input clk;
    //code_w_en: enable write to code memory
    //run: enable run processor
    input code_w_en;
    input run;
    //code_in: code input
    input [15:0] code_in;
    // code_addr_in: code address in
    input [8:0] code_addr_in;
    reg zero;
    reg [15:0] big_zero;
    output [7:0] debug;
    
    initial begin
        zero = 0;
        big_zero = 15'd0;
        // program initials
        // the "macro" to dump signals
        `ifdef COCOTB_SIM
        $dumpfile ("datapath.vcd");
        $dumpvars (0, datapath);
        #1;
        `endif
    end
    

    //
    // control signals
    //
    // signals are the control unit signals wire
    wire [`signals_size-1:0] signals;

    // control if the pc should be incremented in next rising edge
    wire pc_inc;
    assign pc_inc = signals[`s_pc_inc];
    // control if memory address register should be writtenn 
    wire mar_w_en;
    assign mar_w_en = signals[`s_mar_w_en];
    // control if register bank should read or write
    // 0 read
    // 1 write
    wire reg_rw;
    assign reg_rw = signals[`s_reg_rw];
    // control if register data in should be alu out or immediate from ir
    // 0 alu
    // 1 immediatcode_w_ene
    wire reg_select_in;
    assign reg_select_in = signals[`s_reg_sel_in];
    // control if the flags should be written from the alu
    wire flags_w_en;
    assign flags_w_en = signals[`s_flags_w_en];

    
    // pc: program counter
    wire [8:0] pc_write_in;
    assign pc_write_in = pc_inc ? pc+1 : pc;
    wire [8:0] pc;
    register #(9) pc_register(
        .clk(clk),
        .w_en(pc_inc),
        .d_in(pc_write_in),
        .d_out(pc)
    );

    // mar: memory address register
    wire [8:0] mar;
    register #(9) mar_register(
        .clk(clk),
        .w_en(mar_w_en),
        .d_in(pc),
        .d_out(mar)
    );
    
    //
    // code memory
    //
    
    // ir: instruction register
    wire [15:0] ir;

    always @ (posedge clk) $display("el ir es: %h", ir);

    memory_bank #(16, 9) code_mem(
        .clk(clk),
        .w_en(code_w_en),
        .addr(code_w_en ? code_addr_in : mar),
        .d_in(code_in),
        .d_out(ir)
    );

    // immediate: immediate word-sized operand from instruction format
    wire [7:0] immediate;
    assign immediate = ir[7:0];
    
    wire [7:0] alu_out, alu_a, alu_b, alu_flags, flags;
    wire [7:0] reg_data_in;

    assign debug = alu_out;
    
    assign reg_data_in = reg_select_in ? immediate : alu_out; 

    // control unit
    ctrl_unit control(
        .clk(clk & run),
        .opcode(ir[15:11]),
        .signals(signals)
    );

    // processing data path

    register_bank rbank(
        .clk(clk),
        .ri_a(ir[5:3]),
        .ri_b(ir[2:0]),
        .ri_d(ir[10:8]),
        .rw(reg_rw),
        .d(reg_data_in),
        .a(alu_a),
        .b(alu_b)
    );

    register flags_register(
        .clk(clk),
        .w_en(flags_w_en),
        .d_in(alu_flags),
        .d_out(flags)
    );

    alu alu_unit(
        .a(alu_a),
        .b(alu_b),
        .out(alu_out),
        .flags(alu_flags),
        .op(ir[13:11])
    );

endmodule
