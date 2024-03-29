//
// This file was generated by microprogammer.py - DO NOT EDIT MANUALLY
//

`define micro_addr_size     5
`define signals_size    18
// +1 for the decision state bit
`define store_word_size 24


// Enable the IR register to be written
`define s_ir_w_en        0

// Enable the PC to be written in the next cycle
`define s_pc_w_en        1

// Enable the PC reference to be incremented in the next clock cycle.
`define s_pc_ref_inc        2

// Enable the PC reference to be decremented in the next clock cycle.
`define s_pc_ref_dec        3

// Enable the PC to be set in the next clock cycle.
`define s_pc_set        4

// Enable the MAR (memory address register) to be written in the next clock cycle.
`define s_mar_w_en        5

// Enable the register file to be written in the next clock cycle.
`define s_reg_rw        6

// Enable ALU out into data bus
`define s_alu_out_en        7

// Enable flags register into data bus
`define s_flags_en        8

// Enable immediate decoded from IR into data bus
`define s_imm_en        9

// Enable write to the DAR register
`define s_dar_w_en        10

// Enable write to the MDR register
`define s_mdr_w_en        11

// Enable write to the SR register
`define s_sr_w_en        12

// Enable write to the data memory
`define s_dmem_w_en        13

// Enable MDR into data bus
`define s_mdr_out_en        14

// If selected, register bank out A is selected as MDR in
`define s_reg_to_mdr        15

// Enable the flags register to be written in the next clock cycle.
`define s_flags_w_en        16

// Enable RND into data bus.
`define s_rnd_out_en        17
