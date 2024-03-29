`timescale 1ns / 1ps

`include "constants.v"
`include "signals.v"

module datapath(clk, rst, run, code_w_en, code_addr_in, code_in, io_in, io_out);
    input clk, rst;
    //code_w_en: enable write to code memory
    //run: enable run processor
    input code_w_en;
    input run;
    //code_in: code input
    input [15:0] code_in;
    // code_addr_in: code address in
    input [8:0] code_addr_in;

    // IO
    input [3:0] io_in;
    output [3:0] io_out;
    
    initial begin
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

    // ir_w_en: Enable the IR register to be written
    wire ir_w_en;
    assign ir_w_en = signals[`s_ir_w_en];

    // pc_w_en: Enable the PC to be written in the next cycle
    wire pc_w_en;
    assign pc_w_en = signals[`s_pc_w_en];

    // pc_ref_inc: Enable the PC reference to be incremented in the next clock cycle.
    wire pc_ref_inc;
    assign pc_ref_inc = signals[`s_pc_ref_inc];

    // pc_ref_dec: Enable the PC reference to be decremented in the next clock cycle.
    wire pc_ref_dec;
    assign pc_ref_dec = signals[`s_pc_ref_dec];

    // pc_set: Enable the PC to be set in the next clock cycle.
    wire pc_set;
    assign pc_set = signals[`s_pc_set];

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

    // sr_w_en: Enable write to thhe SR register
    wire sr_w_en;
    assign sr_w_en = signals[`s_sr_w_en];

    // dmem_w_en: Enable write to the data memory
    wire dmem_w_en;
    assign dmem_w_en = signals[`s_dmem_w_en];

    // mdr_out_en: Enable MDR into data bus
    wire mdr_out_en;
    assign mdr_out_en = signals[`s_mdr_out_en];

    // reg_to_mdr: If selected, register bank out A is selected as MDR in
    wire reg_to_mdr;
    assign reg_to_mdr = signals[`s_reg_to_mdr];

    // flags_w_en: Enable the flags register to be written in the next clock cycle.
    wire flags_w_en;
    assign flags_w_en = signals[`s_flags_w_en];

    // rnd_out_en: Enable RND into data bus.
    wire rnd_out_en;
    assign rnd_out_en = signals[`s_rnd_out_en];

    // END SIGNALS
    // --------------------------------------------------------------------

    // pc: program counter

    wire [8:0] pc;
    wire err;
    
    pc_module pc_unit(
        .clk(clk), 
        .rst(rst),
        .pc_inc(pc_w_en), 
        .pc_ref_inc(pc_ref_inc), 
        .pc_ref_dec(pc_ref_dec), 
        .pc_set(pc_set), 
        .pc_set_value(ir[8:0]), 
        .pc_out(pc), 
        .err(err)
    );

    // mar: memory address register
    wire [8:0] mar;
    register #(9) mar_register(
        .clk(clk),
        .rst(rst),
        .w_en(mar_w_en),
        .d_in(pc),
        .d_out(mar)
    );
    
    //
    // code memory
    //
    
    wire [15:0] code_mem_out;
    //always @ (posedge clk) $display("el ir es: %h", ir);
    `ifdef COCOTB_SIM
    memory_bank #(16, 9) code_mem(
        .clk(clk),
        .w_en(code_w_en),
        .addr(code_w_en ? code_addr_in : mar),
        .d_in(code_in),
        .d_out(code_mem_out)
    );
    `else
    pp_memory code_mem(
        .clk(clk),
        .w_en(code_w_en),
        .addr(code_w_en ? code_addr_in : mar),
        .d_in(code_in),
        .d_out(code_mem_out)
    );
    `endif

    // ir: instruction register
    wire [15:0] ir;
    register #(16) ir_register(
        .clk(clk),
        .rst(rst),
        .w_en(ir_w_en),
        .d_in(code_mem_out),
        .d_out(ir)
    );

    //always @ (posedge clk) $display("PC: %h - IR: %h", pc, ir);

    //
    // data memory
    //

    //
    // IO
    //

    wire is_io_addr, is_io_out;
    assign is_io_out = (dar_out === `IO_OUT_ADDR);
    assign is_io_addr = (dar_out === `IO_IN_ADDR) | is_io_out;
    

    register #(4) io_out_register(
        .clk(clk),
        .rst(rst),
        .w_en(dmem_w_en & is_io_out),
        .d_in(mdr_out[3:0]), // mando del MDR directo porque la señal de WE de la meoria esta protegida
        .d_out(io_out)
    );

    //
    // END IO
    //

    // data address register
    wire [9:0] dar_out;

    // select the DAR data_in based on the opcode
    // less control signals
    reg [9:0] dar_addr_selection;

    `define direct_load 5'b10000
    `define direct_store 5'b10001
    `define indirect_load 5'b10010
    `define indirect_store 5'b10011
    always @ (*) begin
        casex (opcode)
            `direct_load: dar_addr_selection <= immediate;
            `direct_store: dar_addr_selection <= ir[10:3]; // immediate for memory is addr is on 10:3
            `indirect_load: dar_addr_selection <= alu_a;
            `indirect_store: dar_addr_selection <= alu_a;
            // default to zero
            default: dar_addr_selection <= 8'd0;
        endcase
    end

    wire [9:0] dar_data_in;
    assign dar_data_in = ({2'b00, sr_out} << 2) + dar_addr_selection;

    register #(10) dar_register(
        .clk(clk),
        .rst(rst),
        .w_en(dar_w_en),
        .d_in(dar_data_in),
        .d_out(dar_out)
    );

    wire [7:0] sr_out;
    wire [7:0] alu_out, alu_a, alu_b, alu_flags, flags;
    wire [7:0] rnd_out;

    register sr_register(
        .clk(clk),
        .rst(rst),
        .w_en(sr_w_en),
        .d_in(alu_a),
        .d_out(sr_out)
    );

    // memory data register
    wire [7:0] mdr_out;
    wire [7:0] mdr_in, mem_or_io;
    register mdr_register(
        .clk(clk),
        .rst(rst),
        .w_en(mdr_w_en),
        .d_in(mdr_in),
        .d_out(mdr_out)
    );


    assign mem_or_io = is_io_addr ? {4'd0, io_in} : data_mem_out;
    assign mdr_in = reg_to_mdr ? alu_b : mem_or_io;

    wire [7:0] data_mem_out;
    // default parameters of memory correspond to data memory
    memory_bank data_mem(
        .clk(clk),
        .w_en(dmem_w_en & ~is_io_addr),
        .addr(dar_out),
        .d_in(mdr_out),
        .d_out(data_mem_out)
    );

    // immediate: immediate word-sized operand from instruction format
    wire [7:0] immediate;
    assign immediate = ir[7:0];


    wire [4:0] opcode;
    assign opcode = ir[15:11];
    // control unit
    ctrl_unit control(
        .clk(clk & run),
        .rst(rst),
        .opcode(opcode),
        .flags(flags),
        .signals(signals)
    );

    // data bus
    wire [7:0] data_bus;
    assign data_bus = alu_out_en ? alu_out : 8'bz;
    assign data_bus = flags_en ? flags : 8'bz;
    assign data_bus = imm_en ? immediate : 8'bz;
    assign data_bus = mdr_out_en ? mdr_out : 8'bz;
    assign data_bus = rnd_out_en ? rnd_out : 8'bz;

    // processing data path

    register_bank rbank(
        .clk(clk),
        .rst(rst),
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
        .rst(rst),
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

    random rnd_unit(
        .clk(clk),
        .in(alu_a),
        .rnd_out(rnd_out)
    );

endmodule
