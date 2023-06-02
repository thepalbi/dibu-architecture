import unittest
from parser import *
import logging


logging.basicConfig(level=logging.DEBUG, format='%(name)s %(levelname)s %(message)s')


class ParserTest(unittest.TestCase):
    def test_smoke_parse(self):
        example = """loop: mov r1 r2
        // the instruction below generates a random number
        mov r1 r2
        loop: mov r2 r1
        rnd r1
        mov r1 0b101
        mov r1 0x100
        mov r1 0d7
        // direccionamiento directo
        load r1 [0d14]
        // direccionamiento indirecto
        load r1 [r1]
        // direccionamiento directo
        str [0d14] r1
        // direccionamiento indirecto
        str [r1] r1
        jmp loop
        """
        prog = parse(example)
        for instr in prog.instructions:
            print(instr)

    def test_parse_error(self):
        example = """mov r1 0jd0129
        """
        with self.assertRaises(Exception) as ctx:
            parse(example)
