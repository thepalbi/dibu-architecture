`timescale 1ns / 1ps

`include "constants.v"

// alu implements an 8-bit ALU.
module alu(
    a,
    b,
    op,
    out,
    flags
    );
    
    // INPUTS
    
    // a is the 8bit first operand. 
    // Whenever the operation uses just one operand, a should be used
    input [7:0] a;
    // b is the 8bit first operand
    input [7:0] b;
    // op, selector de funcion de alu
    // todo(pablo): renombrar por func
    input [2:0] op;
    
    // OUTPUTS
    
    // out is the 8bit alu out
    output reg [7:0] out;
    // flags is the 8bit flags out
    output [7:0] flags;
    
    // INTERNAL VARS
    
    wire zero, negative, parity, overflow;
    reg carry;
    
    // COMBINATIONAL LOGIC
    
    assign flags = {3'd0, parity, zero, overflow, negative, carry};
    
    // combinatory flags
    // invert all bits, if all zero it will be 8'b1*, then and bit by bit
    assign zero = &(~out);
    // operadores en ca2, bit mas significativo es signo
    assign negative = out[7];
    // https://en.wikipedia.org/wiki/Parity_function
    assign parity = ~(^out);
    
    // if it's substraction, use the same overflow logic but apply
    // the negative sign to be before, so that a - b => a + (-b)
    wire [7:0] maybe_negated_b = op == `OP_SUB ? (~b + 1) : b;
    assign overflow =
        (a[7] ~^ maybe_negated_b[7]) // si los dos operando tienen el mismo signo
        & (a[7] != out[7]); // y la salida tiene signo diferente, dio la vuelta
    
    always @ (*) begin
        case (op)
            `OP_SUM: begin
                {carry, out} <= a + b;
            end
            `OP_SUB: begin
                out <= a - b;
                carry <= 0;
            end
            `OP_AND: begin
                out <= a & b;
                carry <= 0;
            end
            `OP_OR: begin
                out <= a | b;
                carry <= 0;
            end
            `OP_NOT: begin
                out <= ~a;
                carry <= 0;
            end
            `OP_LSL: begin
                out <= a << b;
                carry <= 0;
            end
            `OP_LSR: begin
                out <= a >> b;
                carry <= 0;
            end
            `OP_ID: begin
                out <= a;
                carry <= 0;
            end
        endcase
    end
endmodule
