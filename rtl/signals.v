//
// This file was generated by microprogammer.py - DO NOT EDIT MANUALLY
//

`define micro_addr_size     5
`define signals_size    7
// +1 for the decision state bit
`define store_word_size 13

// pc_inc: Enable the PC to be incremented in the next clock cycle.
`define s_pc_inc		0
// mar_w_en: Enable the MAR (memory address register) to be written in the next clock cycle.
`define s_mar_w_en		1
// reg_rw: Enable the register file to be written in the next clock cycle.
`define s_reg_rw		2
// alu_out_en: Enable ALU out into data bus
`define s_alu_out_en		3
// flags_en: Enable flags register into data bus
`define s_flags_en		4
// imm_en: Enable immediate decoded from IR into data bus
`define s_imm_en		5
// flags_w_en: Enable the flags register to be written in the next clock cycle.
`define s_flags_w_en		6
