// pc_inc: Enable the PC to be incremented in the next clock cycle.
`define s_pc_inc		0
// mar_w_en: Enable the MAR (memory address register) to be written in the next clock cycle.
`define s_mar_w_en		1
// reg_rw: Enable the register file to be written in the next clock cycle.
`define s_reg_rw		2
// reg_sel_in: Select the origin of data into the register file.
`define s_reg_sel_in		3
// flags_w_en: Enable the flags register to be written in the next clock cycle.
`define s_flags_w_en		4
// alu_out_select: Pick wether the output from the alu is the alu out (0), or the flags register (1)
`define s_alu_out_select		5
