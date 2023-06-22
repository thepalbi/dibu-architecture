from cocotb.regression import Test
import sys


def get_stuff(test_module):
    tests = []
    mod = __import__(test_module)
    topmodel = vars(mod)["TOPMODEL"]
    sources = vars(mod)["VERILOG_SOURCES"]
    for thing in vars(mod).values():
        if isinstance(thing, Test):
            tests.append(thing.name)
    return tests, topmodel, sources

if __name__ == "__main__":
    mod_name = sys.argv[1]
    tests, topmodel, sources = get_stuff(mod_name)
    match sys.argv[2]:
        case "tests": print(" ".join(tests), end="")
        case "toplevel": print(topmodel)
        case "sources": print(sources)
        case _: raise ValueError

