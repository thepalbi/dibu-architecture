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
    
    wire zero, negative, parity, overflow, carry;
    
    // COMBINATIONAL LOGIC
    
    assign flags = {3'd0, parity, zero, overflow, negative, carry};
    
    // combinatory flags
    assign zero = (out == 8'd0) ? 1 : 0;
    // operadores en ca2, bit mas significativo es signo
    assign negative = out[7];
    // https://en.wikipedia.org/wiki/Parity_function
    assign parity = ~(^out);
    
    wire overflow_add, overflow_sub;
    
    assign overflow_add = 
        (a[7] ~^ b[7]) // si los dos operando tienen el mismo signo
        & (b[7] != out[7]); // y la salida tiene signo diferente, dio la vuelta
        
    assign overflow_sub = 
        (~a[7] & b[7] & out[7]) |
        (a[7] & ~b[7] & ~out[7]);
    
    assign overflow = overflow_add | overflow_sub;
    
    assign carry = t_carry | 0;
    
    // PREGUNTA: que hacemo con el carry deivid?
    reg t_carry;
    initial begin; t_carry = 0; end
    
    always @ (*) begin
        case (op)
            `OP_SUM: begin
                {t_carry, out} <= a + b;
            end
            `OP_SUB: out <= a - b;
            `OP_AND: out <= a & b;
            `OP_OR: out <= a | b;
            `OP_NOT: out <= ~a;
            `OP_LSL: out <= a << b;
            `OP_LSR: out <= a >> b;
            // todo(pablo): add here a debugger log
            default begin
                $display("unsupported alu op: %b", op);
            end
        endcase
    end
endmodule
