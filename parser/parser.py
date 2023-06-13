from lark import Lark, Visitor, Tree, Token
from dataclasses import dataclass
from typing import List, Dict, Tuple
from os import path
import logging
from enum import Enum
from bitstring import Bits

log = logging.getLogger(__name__)

"""
DiBU parser and assambler, based in a EBNF grammar.

References:

http://blog.erezsh.com/how-to-write-a-dsl-in-python-with-lark/
https://github.com/antlr/grammars-v4/blob/master/asm/asm8086/asm8086.g4
"""

INSTRUCTION_SIZE = 16

CURRENT_DIR = path.dirname(path.realpath(__file__))

class ProgramVisitor(Visitor):
    def __init__(self) -> None:
        self._labels = {}
        self._instructions = []
        self._comments = []
        self._seen_instruction_lines = 0
        super().__init__()

    def code(self, code_tree):
        code_visitor = CodeLineVisitor()
        # visit code and create instruction
        code_visitor.visit_topdown(code_tree)
        self._instructions.append(code_visitor.produce_instruction())
        # record that we've seen the instruction after visiting the label
        self._seen_instruction_lines += 1

    def comment(self, c: Tree):
        self._comments.append(c.children[0].value)

    def label(self, l: Tree):
        # when visiting the label, take as the amount of seen lines one less,
        # since we've visited first the line item, and then the label
        # todo(pablo): this is not working that good
        self._labels[l.children[0].value] = (
            self._seen_instruction_lines - 1) * INSTRUCTION_SIZE

    def produce_program(self):
        return Program(
            instructions=self._instructions,
            labels=self._labels,
        )

class OperandType(Enum):
    REGISTER = "reg"
    IMMEDIATE = "imm"
    MEM_REGISTER = "mem_reg"
    MEM_IMMEDIATE = "mem_imm"

@dataclass
class Instruction:
    opcode: str
    operands: List[Tuple[OperandType, any]]

    def __repr__(self) -> str:
        return "%s %s" % (self.opcode, " ".join([op[1] for op in self.operands]))

    def print_format(self) -> str:
        return "%s %s" % (self.opcode, " ".join([op[0].value for op in self.operands]))


@dataclass
class Program:
    instructions: List[Instruction]
    labels: Dict[str, int]
                

class CodeLineVisitor(Visitor):
    def __init__(self) -> None:
        self._operands = []
        super().__init__()

    def opcode(self, o: Tree):
        self._opcode = o.children[0].value

    #
    # operands
    #
    def register_operand(self, reg: Tree):
        self._operands.append(
            (OperandType.REGISTER, reg.children[0].value)
        )

    def immediate_operand(self, imm: Tree):
        value: Tree = imm.children[0]
        parsed_immediate_value = self.parse_immediate(value)
        self._operands.append(
            (OperandType.IMMEDIATE, parsed_immediate_value)
        )

    def parse_immediate(self, value: Tree):
        # todo(pablo): check maximum supported bit length in immediate and fail fast
        IMMEDIATE_LENGTH=8
        match value.data:
            case "binary": return Bits(bin=value.children[0].value, length=IMMEDIATE_LENGTH).bin
            case "hexa": return Bits(hex=value.children[0].value, length=IMMEDIATE_LENGTH).bin
            case "decimal": return Bits(int=int(value.children[0].value[2:]), length=IMMEDIATE_LENGTH).bin
            case _: raise ValueError("unsupported immediate operand type: %s" % (value.data))

    def mem_indirect(self, reg: Tree):
        self._operands.append(
            (OperandType.MEM_REGISTER, reg.children[0].value)
        )

    def mem_direct(self, imm: Tree):
        self._operands.append(
            (OperandType.MEM_IMMEDIATE, self.parse_immediate(imm.children[0]))
        )

    def produce_instruction(self) -> Instruction:
        return Instruction(
            opcode=self._opcode,
            operands=self._operands,
        )

OT = OperandType

def assemble(p: Program, format="binary") -> str:
    """
    assemble assembles a Program p into it's binary representation.

    :param Program p: the program to assemble
    :param str format: the format to encode the assembled program
    :return str: the assembled program
    """
    result = ""
    for i in p.instructions:
        match i:
            case Instruction("mov", [(OT.REGISTER, r1), (OT.REGISTER, r2)]):
                result += "00111%s00%s000\n" % (asm_register(r1), asm_register(r2))
            case Instruction("mov", [(OT.REGISTER, r1), (OT.IMMEDIATE, imm)]):
                result += "01000%s%s\n" % (asm_register(r1), imm)
            case Instruction("not", [(OT.REGISTER, r1), (OT.REGISTER, r2)]):
                result += "00110%s00%s000\n" % (asm_register(r1), asm_register(r2))
            case _: raise ValueError("unsupported instruction: %s" % (i.print_format()))

    return result

def asm_register(reg) -> str:
    register_num = int(reg[1:])
    return Bits(uint=register_num, length=3).bin


# initialize parser with grammar
with open(path.join(CURRENT_DIR, "grammar.lark"), "r") as f:
    grammar = f.read()
_parser = Lark(grammar, start="prog")

def parse(text: str) -> Program:
    """
    parse parses the given string into a Program object

    :param str text: the program to parse
    :return Program: the parsed and processed program
    """    
    parsed_tree = _parser.parse(text)
    
    # if debug is enabled, this will print the parsed tree
    log.debug(parsed_tree.pretty())

    print("compiling tree")
    visitor = ProgramVisitor()
    visitor.visit_topdown(parsed_tree)

    return visitor.produce_program()
    