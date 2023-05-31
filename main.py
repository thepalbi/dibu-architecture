from lark import Lark, Tree
from lark.lexer import Token

# https://github.com/antlr/grammars-v4/blob/master/asm/asm8086/asm8086.g4

with open("grammar.txt", "r") as f:
    grammar = f.read()

parser = Lark(grammar)

example = """loop: mov r1 r2
// the instruction below generates a random number
rnd r1
mov r1 b101
"""

parsed_tree = parser.parse(example)
print(parsed_tree.pretty())

print("compiling tree")

# first, prog contains a series of lines, each can be code or comment
for line in parsed_tree.children:
    for ch in line.children:
        print(ch)
        # token: Token = line
        # match token.type:
        #     case 'comment_line': print("comment")
        #     case 'code': print("code")
        #     case _: print("unsupported type: %s" % (token.type))
