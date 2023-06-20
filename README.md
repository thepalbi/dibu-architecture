## DiBU: DIgilent Based Unit

DiBU is a processor designed from the grounds up, with it's own [ISA](https://www.overleaf.com/read/fgpwwyyhspns), designed to run on an FGPA board.

## Installation

```
sudo apt-get install python-setuptools
python -m venv env
source env/bin/activate
pip install -r requirements.txt

# update apt deps
sudo apt-get update
sudo apt-get install verilog

# install gtkwave for debugging waveforms
sudo apt-get install gtkwave
```

## Testing

For all the commands below, first the virtual env needs to be activated by running `source env/bin/activate`.

### Assembler and parser

Run the following from the repo root.
```bash
make test
```

### RTL

```

```
