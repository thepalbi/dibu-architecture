`timescale 1ns / 1ps

// alu implements an 8-bit ALU.
module alu(
    a,
    b,
    op,
    out,
    zero,
    negative,
    carry,
    overflow,
    parity
    );
    
    // a is the 8bit first operand. 
    // Whenever the operation uses just one operand, a should be used
    input [7:0] a;
    // b is the 8bit first operand
    input [7:0] b;
    
    //
    // supported ops and their codes
    //
    localparam OP_SUM = 0'd0;
    localparam OP_SUB = 0'd1;
    localparam OP_AND = 0'd2;
    localparam OP_OR = 0'd3;
    localparam OP_LSL = 0'd4;
    localparam OP_LSR = 0'd5;
    localparam OP_NOT = 0'd6;
    
    // todo(pablo): this should be 3-bit
    // op is the 4-bit alu function code. Possible values are described
    // in the section above
    input [3:0] op;
    
    // out is the 8bit alu out
    output reg [7:0] out;
    
    // todo(pablo): this should be a single 8bit bus, and saved in registers
    output zero, negative, parity, overflow, carry;
    
    
    // combinatory flags
    assign zero = (out == 8'd0) ? 1 : 0;
    // operadores en ca2, bit mas significativo es signo
    assign negative = out[7];
    // https://en.wikipedia.org/wiki/Parity_function
    assign parity = ^out;
    
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
    
    always @ (*) begin
        case (op)
            OP_SUM: begin
                {t_carry, out} <= a + b;
            end
            OP_SUB: out <= a - b;
            OP_AND: out <= a & b;
            OP_OR: out <= a | b;
            OP_NOT: out <= ~a;
            OP_LSL: out <= a << b;
            OP_LSR: out <= a >> b;
            // todo(pablo): add here a debugger log
            default: out <= 8'd0;
        endcase
    end
endmodule