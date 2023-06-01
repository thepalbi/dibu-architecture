import unittest
from parser import *

class ParserTest(unittest.TestCase):
    def test_smoke_parse(self):
        example = """loop: mov r1 r2
        // the instruction below generates a random number
        mov r1 r2
        loop: mov r2 r1
        rnd r1
        mov r1 b101
        jmp loop
        """
        prog = parse(example)
        print(prog)
