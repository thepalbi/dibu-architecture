import unittest
from dibuparser import *
import logging
import textwrap


logging.basicConfig(level=logging.DEBUG,
                    format='%(name)s %(levelname)s %(message)s')


def prepare_binary(b: str) -> str:
    b = textwrap.dedent(b)
    # remove leading whitespace
    b = b.lstrip("\n")
    # check only one new line is after
    if b[-1] != "\n":
        b += "\n"
    return b


class ParserTest(unittest.TestCase):
    @unittest.skip("disabling for only supporting certain ops in parsing")
    def test_smoke_parse(self):
        example = """loop: mov r1 r2
        ; the instruction below generates a random number
        mov r1 r2
        loop: mov r2 r1
        rnd r1
        mov r1 0b101
        mov r1 0x100
        mov r1 0d7
        ; direccionamiento directo
        load r1 [0d14]
        ; direccionamiento indirecto
        load r1 [r1]
        ; direccionamiento directo
        str [0d14] r1
        ; direccionamiento indirecto
        str [r1] r1
        jmp loop
        """
        prog = parse(example)
        for instr in prog.instructions:
            print(instr)

    @unittest.skip("disabling for only supporting certain ops in parsing")
    def test_parser_returns_expected_program(self):
        example = """mov r1 r2
        rnd r1
        mov r1 0b101
        load r1 [0d14]
        load r1 [r1]
        """
        prog = parse(example)
        expected = Program(
            instructions=[
                Instruction("mov", [
                    (OperandType.REGISTER, "r1"),
                    (OperandType.REGISTER, "r2"),
                ]),
                Instruction("rnd", [
                    (OperandType.REGISTER, "r1")
                ]),
                Instruction("mov", [
                    (OperandType.REGISTER, "r1"),
                    (OperandType.IMMEDIATE, "0b101"),
                ]),
                Instruction("load", [
                    (OperandType.REGISTER, "r1"),
                    (OperandType.MEM_IMMEDIATE, bin(14)),
                ]),
                Instruction("load", [
                    (OperandType.REGISTER, "r1"),
                    (OperandType.MEM_REGISTER, "r1"),
                ]),
            ],
            labels={},
        )
        self.assertEqual(prog, expected)

    def test_parser_calculates_label_map_correctly(self):
        example = """start: mov r1 0x0f
        mov r1 0d0
        jmp start
        end: halt
        jmp end
        je end
        jne end
        jn end
        """
        prog = parse(example)
        expected = Program(
            instructions=[
                Instruction("mov", [
                    (OperandType.REGISTER, "r1"),
                    (OperandType.IMMEDIATE, "00001111"),
                ]),
                Instruction("mov", [
                    (OperandType.REGISTER, "r1"),
                    (OperandType.IMMEDIATE, "0"*8),
                ]),
                Instruction("jmp", [
                    (OperandType.LABEL, "start"),
                ]),
                Instruction("halt", []),
                Instruction("jmp", [
                    (OperandType.LABEL, "end"),
                ]),
                Instruction("je", [
                    (OperandType.LABEL, "end"),
                ]),
                Instruction("jne", [
                    (OperandType.LABEL, "end"),
                ]),
                Instruction("jn", [
                    (OperandType.LABEL, "end"),
                ]),
            ],
            labels={
                "start": 0,
                "end": 3,
            },
        )
        self.assertEqual(prog, expected)
        expected = prepare_binary("""
        0100000100001111
        0100000100000000
        1100000000000000
        1111111111111111
        1100000000000011
        1100100000000011
        1101000000000011
        1101100000000011
        """)
        assembled_program = assemble(prog)
        self.assertEqual(expected, assembled_program)


    def test_parse_error(self):
        example = """mov r1 0jd0129
        """
        with self.assertRaises(Exception) as ctx:
            parse(example)

    def test_assemble_simple_program(self):
        example = """rodru: mov r3 0xf0
        mov r4 r3
        not r5 r4
        """
        # todo: improve this to ignore tailing and leading whitespace, and also dedent
        expected = prepare_binary("""
        0100001111110000
        0011110000011000
        0011010100100000
        """)
        parsed_program = parse(example)
        assembled_program = assemble(parsed_program)
        self.assertEqual(expected, assembled_program)

    def test_assemble_error(self):
        with self.assertRaises(ValueError) as ctx:
            example = """mov 0d14 0d14
            """
            parsed_program = parse(example)
            # this should fail due to the instruction above being invalid
            assemble(parsed_program)
        # log the exception
        print(ctx.exception)
