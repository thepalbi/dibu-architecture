from typing import List, Optional
from bitstring import Bits
from dataclasses import dataclass


# the following contains all supported signals, in the order they show in the microsintruction
# each symbol will be allowed in the microprogram file. Also, the first is the lowest bit (0), and
# the last the highest.
TEMPLATE = [
    "decision",  # least significant bit
    "pc_inc",
    "mar_w_en",
    "reg_rw",  # todo: maybe rename to reg_w_en
    "reg_sel_in",
    "flags_w_en"
    # hightest significance
]


@dataclass
class MicroInstruction:
    signals: List[str]
    goto: Optional[str] = None
    label: Optional[str] = None


_ = MicroInstruction

program = [
    _(["mar_w_en", "pc_inc"], label="fetch"),
    _([], goto="decision"),

    # mov r, r
    _([]),
    _([], goto="fetch"),

    # op r,r,r
    _([]),
    _(["flags_w_en", "reg_rw"], goto="fetch"),

    # mov r, imm
    _(["reg_sel_in", "reg_rw"], goto="fetch"),

    # decision state, goto here is ignored using zero
    _(["decision"], label="decision", goto="fetch")
]

ADDR_START_BIT = 6

if __name__ == "__main__":
    # build symbol table
    symbol_to_mask = {}

    gotos = {}
    # build goto table
    for addr, instr in enumerate(program):
        if instr.label is not None:
            gotos[instr.label] = addr

    result = []
    for i, sym in enumerate(TEMPLATE):
        symbol_to_mask[sym] = 1 << i

    for curr_addr, instr in enumerate(program):
        compiled_line = 0
        for sym in instr.signals:
            try:
                compiled_line |= symbol_to_mask[sym]
            except KeyError:
                raise ValueError("unknown symbol %s" % (sym))
        if instr.goto is not None:
            try:
                goto_addr = gotos[instr.goto]
                # todo: extract
                compiled_line |= goto_addr << ADDR_START_BIT
            except KeyError:
                raise ValueError("undefined goto label: %s" % (instr.goto))
        else:
            compiled_line |= (curr_addr+1) << ADDR_START_BIT
        result.append(compiled_line)

    output = "\n".join([
        Bits(uint=l, length=9).bin for l in result
    ])
    print("compiled output program\n%s" % (output))

    print("written to file")
    with open("microprogram_clean.mem", "w") as f:
        f.write(output)

# todo: add code to also generate a signals.v that has which bit is which signal out of the control uni
# this this is the only file with the actual definition, and in the datapath we can access to signals like
# signals[`reg_w_en] ?
