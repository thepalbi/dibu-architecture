from jinja2 import Environment, PackageLoader, select_autoescape
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
    # enables into data bus
    ("alu_out_en", "Enable ALU out into data bus"),
    ("flags_en", "Enable flags register into data bus"),
    ("imm_en", "Enable immediate decoded from IR into data bus"),
    # memory stuff
    ("dar_w_en", "Enable write to the DAR register"),
    ("mdr_w_en", "Enable write to the MDR register"),
    ("mem_w_en", "Enable write to the data memory"),
    ("mdr_out_en", "Enable MDR into data bus"),
    ("reg_to_mar", "If selected, register bank out A is selected as MDR in"),
    # other stuff
    ("flags_w_en", "Enable the flags register to be written in the next clock cycle."),
    # hightest significance
]
ADDR_START_BIT = len(SUPPORTED_SIGNALS)
# ADDRESS_BITS are the number of bits for the micro instruction address
ADDRESS_BITS = 5
MICROINST_LENGHT = len(SUPPORTED_SIGNALS)+ADDRESS_BITS


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
    _(["reg_rw", "alu_out_en"], goto="fetch"),

    # op r,r,r
    _([]),
    _(["flags_w_en", "reg_rw", "alu_out_en"], goto="fetch"),

    # mov r, imm
    _(["imm_en", "reg_rw"], goto="fetch"),

    # movf r
    _(["reg_rw", "flags_en"], goto="fetch"),

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


def compile_microcode() -> str:
    for curr_addr, instr in enumerate(program):
        compiled_line = 0
        for sym in instr.signals:
            try:
                compiled_line |= symbol_to_mask[sym]
            except KeyError:
                raise ValueError("unknown symbol %s" % (sym))
        # microinstr has a goto statement, pick next address from labels
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
        Bits(uint=l, length=MICROINST_LENGHT).bin for l in result
    ])


jinja_env = Environment(
    loader=PackageLoader("dibu"),
    autoescape=select_autoescape()
)


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
        f.write(
            jinja_env.get_template("signals.jinja").render(
                micro_addr_size=ADDRESS_BITS,
                signals_size=len(SUPPORTED_SIGNALS)-1,
                microinstruction_size=ADDRESS_BITS+len(SUPPORTED_SIGNALS),
                signals=enumerate(SUPPORTED_SIGNALS),
            )
        )

    log.info("done")

    datapath_signals_mapping = ""
    for i, [signal, comment] in enumerate(SUPPORTED_SIGNALS):
        if signal == "decision":
            continue
        datapath_signals_mapping += "// %s: %s\n" % (signal, comment)
        datapath_signals_mapping += "wire %s;\n" % (signal)
        datapath_signals_mapping += f"assign {signal} = signals[`s_{signal}];\n"
        datapath_signals_mapping += "\n"

    print("copy this bit into the datapath definition")
    print(datapath_signals_mapping)