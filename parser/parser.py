from lark import Lark, Visitor, Tree, Token
from dataclasses import dataclass
from typing import List, Dict, Tuple
from os import path
import logging
from enum import Enum

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
    REGISTER = 1
    IMMEDIATE = 2

@dataclass
class Instruction:
    opcode: str
    operands: List[Tuple[OperandType, any]]

    def __repr__(self) -> str:
        return "%s %s" % (self.opcode, " ".join([op[1] for op in self.operands]))


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
        # todo(pablo): check maximum supported bit length in immediate and fail fast
        match value.data:
            case "binary": self._operands.append(
                    (OperandType.IMMEDIATE, bin(int(value.children[0].value[2:], 2)))
            )
            case "hexa": self._operands.append(
                    (OperandType.IMMEDIATE, bin(int(value.children[0].value[2:], 16)))
            )
            case "decimal": self._operands.append(
                    (OperandType.IMMEDIATE, bin(int(value.children[0].value[2:], 10)))
            )
            case _: raise ValueError("unsupported immediate operand type: %s" % (value.data))

    def produce_instruction(self) -> Instruction:
        return Instruction(
            opcode=self._opcode,
            operands=self._operands,
        )


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
    