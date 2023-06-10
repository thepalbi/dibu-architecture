from bitstring import Bits
from dataclasses import dataclass
from enum import Enum
from typing import Union


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


IntOrString = Union[int, str]


@dataclass
class TestCase:
    a: IntOrString
    b: IntOrString
    expected_out: IntOrString
    alu_op: ALUOp
    expected_flags: int
    ignore_flags: bool = False

    def render(self):
        return "%s_%s_%s_%s_%s_%s" % (
            format_bitstring(self.a, 8),
            format_bitstring(self.b, 8),
            format_bitstring(self.expected_out, 8),
            Bits(uint=self.alu_op.value, length=3).bin,
            format_bitstring(self.expected_flags, 8),
            '1' if self.ignore_flags else '0',
        )


# flags
NONE = 0b0
CARRY = 0b1
NEGATIVE = 0b1 << 1
OVERFLOW = 0b1 << 2
ZERO = 0b1 << 3
PARITY = 0b1 << 4


def format_bitstring(v, width) -> str:
    if isinstance(v, str):
        return Bits(auto=v).bin
    else:
        return Bits(int=v, length=width).bin


testcases = [
    TestCase(10, 11, 21, ALUOp.ADD, NONE),
    # carry expected here since in unsigned, it's 2**8-1  + 1, going over resolution
    TestCase(1, -1, 0, ALUOp.ADD, ZERO | PARITY | CARRY),
    TestCase(0, -1, -1, ALUOp.ADD, NEGATIVE | PARITY),
    TestCase(10, 6, 4, ALUOp.SUB, NONE),
    TestCase(-10, 6, -16, ALUOp.SUB, PARITY | NEGATIVE),
    # overflow cases. 8bit 2 complement goes from [-128 to 127]
    TestCase(-128, 1, 127, ALUOp.SUB, OVERFLOW),
    TestCase(127, 1, -128, ALUOp.ADD, OVERFLOW | NEGATIVE),
    # logical ops
    TestCase(0b111, 0b101, 0b101, ALUOp.AND, PARITY),
    TestCase(0b010, 0b100, 0b110, ALUOp.OR, PARITY),
    TestCase("0x0f", 4, "0xf0", ALUOp.LSL, NONE, ignore_flags=True),
    TestCase("0xf0", 4, "0x0f", ALUOp.LSR, NONE, ignore_flags=True),
    TestCase("0xf0", 4, "0x0f", ALUOp.NOT, NONE, ignore_flags=True),
]

for tc in testcases:
    print(tc.render())
