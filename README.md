## DiBU: DIgilent Based Unit

DiBU is a processor designed from the grounds up, with it's own [ISA](https://www.overleaf.com/read/fgpwwyyhspns), designed to run on an FGPA board. This repo follows the following folder structure:

- `constraints`: Constraint files to program DiBU into FPGAs.
- `dibu`: Python package where some utils are located, such as the micro-program generator.
- `dibuparser`: Python package with the parser and assembler code.
- `programs`: Collection of programs programmed in dibu-assembler.
- `rtl`: VHDL (Verilog) implementation of DiBU.
- `rlt_tests`: Cocotb tests of all DiBU components, and the complete assembly of them. The most interesting test benches are in `test_datapath.py`.
- `tests`: Python tests for the parser and assemble code.

## Docs

See [docs/README.md](./docs/README.md).

## Installation

```
sudo apt-get install python3.10 libpython3.10 python-setuptools 
python3.10 -m venv env
source env/bin/activate
pip install -r requirements.txt

# update apt deps
sudo apt-get update
sudo apt-get install verilog

# install gtkwave for debugging waveforms
sudo apt-get install gtkwave
```

## Testing

For all the commands below, first the virtual env needs to be activated by running `source env/bin/activate`. Also, all commands should be run the following from the repo root.

```
# test parser and assembler programs
make test

# test rtl
make test-rtl
```

## Assemble a program

Command should be run from repo root.

```
python -m dibuparser.parser --file programs/simon.s --outfile rtl/simon.mem --macros
```
