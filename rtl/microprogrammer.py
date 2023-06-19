from typing import List, Optional
from bitstring import Bits
from dataclasses import dataclass
import logging
import argparse

logging.basicConfig(level=logging.INFO)
log = logging.getLogger()


# the following contains all supported signals, in the order they show in the microsintruction
# each symbol will be allowed in the microprogram file. Also, the first is the lowest bit (0), and
# the last the highest.
SUPPORTED_SIGNALS = [
    # least significant bit
    ("decision", "When enabled, means we are in the decision state of the control unit."),
    ("pc_inc", "Enable the PC to be incremented in the next clock cycle."),
    ("mar_w_en", "Enable the MAR (memory address register) to be written in the next clock cycle."),
    # todo: maybe rename to reg_w_en
    ("reg_rw", "Enable the register file to be written in the next clock cycle."),
    ("reg_sel_in", "Select the origin of data into the register file."),
    ("flags_w_en", "Enable the flags register to be written in the next clock cycle."),
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
    _(["reg_rw"], goto="fetch"),

    # op r,r,r
    _([]),
    _(["flags_w_en", "reg_rw"], goto="fetch"),

    # mov r, imm
    _(["reg_sel_in", "reg_rw"], goto="fetch"),

    # decision state, goto here is ignored using zero
    _(["decision"], label="decision", goto="fetch")
]

# build symbol table
symbol_to_mask = {}

gotos = {}
# build goto table
for addr, instr in enumerate(program):
    if instr.label is not None:
        gotos[instr.label] = addr

result = []
for i, [sym, _] in enumerate(SUPPORTED_SIGNALS):
    symbol_to_mask[sym] = 1 << i

ADDR_START_BIT = 6


def compile_microcode() -> str:
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

    return "\n".join([
        Bits(uint=l, length=9).bin for l in result
    ])


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--output-program", dest="output_program", type=str,
                        help="Path were to write the output microprogram", required=True)
    parser.add_argument("--output-constants", dest="output_constants", type=str,
                        help="Path were to write the output verilog constants file", required=True)
    args = parser.parse_args()

    output = compile_microcode()

    log.debug("compiled output program: %s", output)
    log.info("written to file!")

    with open(args.output_program, "w") as f:
        f.write(output)

    with open(args.output_constants, "w") as f:
        for i, [signal, comment] in enumerate(SUPPORTED_SIGNALS):
            if signal == "decision":
                continue
            f.write("// %s: %s\n" % (signal, comment))
            f.write("`define s_%s\t\t%d\n" % (signal, i-1))

    log.info("done")

# todo: add code to also generate a signals.v that has which bit is which signal out of the control uni
# this this is the only file with the actual definition, and in the datapath we can access to signals like
# signals[`reg_w_en] ?
