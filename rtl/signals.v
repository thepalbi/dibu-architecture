// decision: When enabled, means we are in the decision state of the control unit.
`define s_decision		0
// pc_inc: Enable the PC to be incremented in the next clock cycle.
`define s_pc_inc		1
// mar_w_en: Enable the MAR (memory address register) to be written in the next clock cycle.
`define s_mar_w_en		2
// reg_rw: Enable the register file to be written in the next clock cycle.
`define s_reg_rw		3
// reg_sel_in: Select the origin of data into the register file.
`define s_reg_sel_in		4
// flags_w_en: Enable the flags register to be written in the next clock cycle.
`define s_flags_w_en		5
