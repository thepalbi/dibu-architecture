from enum import Enum


class ALUOp(Enum):
    """
    ALUOp represents and ALU operation code.
    """
    ADD = 0
    SUB = 1
    AND = 2
    OR = 3
    LSL = 4
    LSR = 5
    NOT = 6
