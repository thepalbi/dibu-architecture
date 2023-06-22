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

    // --------------------------------------------------------------------
    // START SIGNALS MAPPING - COPY HERE generated code from microprogammer

    // pc_inc: Enable the PC to be incremented in the next clock cycle.
    wire pc_inc;
    assign pc_inc = signals[`s_pc_inc];

    // mar_w_en: Enable the MAR (memory address register) to be written in the next clock cycle.
    wire mar_w_en;
    assign mar_w_en = signals[`s_mar_w_en];

    // reg_rw: Enable the register file to be written in the next clock cycle.
    wire reg_rw;
    assign reg_rw = signals[`s_reg_rw];

    // alu_out_en: Enable ALU out into data bus
    wire alu_out_en;
    assign alu_out_en = signals[`s_alu_out_en];

    // flags_en: Enable flags register into data bus
    wire flags_en;
    assign flags_en = signals[`s_flags_en];

    // imm_en: Enable immediate decoded from IR into data bus
    wire imm_en;
    assign imm_en = signals[`s_imm_en];

    // dar_w_en: Enable write to the DAR register
    wire dar_w_en;
    assign dar_w_en = signals[`s_dar_w_en];

    // mdr_w_en: Enable write to the MDR register
    wire mdr_w_en;
    assign mdr_w_en = signals[`s_mdr_w_en];

    // mem_w_en: Enable write to the data memory
    wire mem_w_en;
    assign mem_w_en = signals[`s_mem_w_en];

    // mdr_out_en: Enable MDR into data bus
    wire mdr_out_en;
    assign mdr_out_en = signals[`s_mdr_out_en];

    // reg_to_mar: If selected, register bank out A is selected as MDR in
    wire reg_to_mar;
    assign reg_to_mar = signals[`s_reg_to_mar];

    // flags_w_en: Enable the flags register to be written in the next clock cycle.
    wire flags_w_en;
    assign flags_w_en = signals[`s_flags_w_en];

    // END SIGNALS
    // --------------------------------------------------------------------

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


    //
    // data memory
    //

    // data address register
    wire [9:0] dar_out;
    register dar_register(
        .clk(clk),
        .w_en(dar_w_en),
        .d_in({2'b00, immediate}),
        .d_out(dar_out)
    );

    // memory data register
    wire [7:0] mdr_out;
    wire [7:0] mdr_in;
    register mdr_register(
        .clk(clk),
        .w_en(mdr_w_en),
        .d_in(mdr_in),
        .d_out(mdr_out)
    );

    assign mdr_in = reg_to_mar ? alu_a : data_mem_out;

    wire [7:0] data_mem_out;
    memory_bank #(8, 10) data_mem(
        .clk(clk),
        .w_en(mem_w_en),
        .addr(dar_out),
        .d_in(mdr_out),
        .d_out(data_mem_out)
    );

    // immediate: immediate word-sized operand from instruction format
    wire [7:0] immediate;
    assign immediate = ir[7:0];
    
    wire [7:0] alu_out, alu_a, alu_b, alu_flags, flags;

    assign debug = alu_out;
    
    // control unit
    ctrl_unit control(
        .clk(clk & run),
        .opcode(ir[15:11]),
        .signals(signals)
    );

    // data bus
    wire [7:0] data_bus;
    assign data_bus = alu_out_en ? alu_out : 8'bz;
    assign data_bus = flags_en ? flags : 8'bz;
    assign data_bus = imm_en ? immediate : 8'bz;
    assign data_bus = mdr_out_en ? mdr_out : 8'bz;

    // processing data path

    register_bank rbank(
        .clk(clk),
        .ri_a(ir[5:3]),
        .ri_b(ir[2:0]),
        .ri_d(ir[10:8]),
        .rw(reg_rw),
        .d(data_bus),
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
