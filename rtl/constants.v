// contants.v contains project wide defines and macros

// alu ops
`define OP_SUM  3'd0
`define OP_SUB  3'd1
`define OP_AND  3'd2
`define OP_OR   3'd3
`define OP_LSL  3'd4
`define OP_LSR  3'd5
`define OP_NOT  3'd6
`define OP_ID  3'd7

// ALU flag positions
`define FLAG_CARRY      0
`define FLAG_NEGATIVE   1
`define FLAG_OVERFLOW   2
`define FLAG_ZERO       3
`define FLAG_PARITY     4

// defaults for dibu
`define DATA_WORD_SIZE 8
`define DATA_ADDR_SIZE 10