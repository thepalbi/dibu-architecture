from bitstring import Bits
from dataclasses import dataclass
from enum import Enum


class ALUOp(Enum):
    """
    ALUOp represents and ALU operation code.
    """
    SUM = 0
    SUB = 1
    AND = 2
    OR = 3
    LSL = 4
    LSR = 5
    NOT = 6


@dataclass
class TestCase:
    a: int
    b: int
    expected_out: int
    alu_op: ALUOp
    expected_flags: int

    def render(self):
        return "%s_%s_%s_%s_%s" % (
            format_bitstring(self.a, 8),
            format_bitstring(self.b, 8),
            format_bitstring(self.expected_out, 8),
            format_bitstring(self.alu_op.value, 3),
            format_bitstring(self.expected_flags, 5),
        )


# flags
NONE = 0b0
CARRY = 0b1
NEGATIVE = 0b1 << 1
OVERFLOW = 0b1 << 2
ZERO = 0b1 << 3
PARITY = 0b1 << 4


def format_bitstring(v, width) -> str:
    return Bits(int=v, length=width).bin


testcases = [
    TestCase(10, 10, 20, ALUOp.SUM, NONE),
    TestCase(1, -1, 0, ALUOp.SUM, ZERO),
]

for tc in testcases:
    print(tc.render())
