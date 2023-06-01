from lark import Lark, Visitor, Tree, Token
from dataclasses import dataclass
from typing import List, Dict
from os import path

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


@dataclass
class Instruction:
    opcode: str


@dataclass
class Program:
    instructions: List[Instruction]
    labels: Dict[str, int]


class CodeLineVisitor(Visitor):
    def __init__(self) -> None:
        super().__init__()

    def opcode(self, o: Tree):
        self._opcode = o.children[0].value

    def produce_instruction(self) -> Instruction:
        return Instruction(
            opcode=self._opcode,
        )


with open(path.join(CURRENT_DIR, "grammar.lark"), "r") as f:
    grammar = f.read()

parser = Lark(grammar, start="prog")

example = """loop: mov r1 r2
// the instruction below generates a random number
mov r1 r2
loop: mov r2 r1
rnd r1
mov r1 b101
jmp loop
"""

parsed_tree = parser.parse(example)
print(parsed_tree.pretty())

print("compiling tree")
visitor = ProgramVisitor()
visitor.visit_topdown(parsed_tree)

program = visitor.produce_program()
print(program)
